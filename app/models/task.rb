class Task < ApplicationRecord
  include AASM
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # --- Elasticsearch index configuration ---
  settings index: {
    number_of_shards: 1,
    analysis: {
      filter: {
        autocomplete_filter: {
          type: "edge_ngram",
          min_gram: 2,
          max_gram: 20
        }
      },
      analyzer: {
        autocomplete: {
          type: "custom",
          tokenizer: "standard",
          filter: ["lowercase", "autocomplete_filter"]
        },
        autocomplete_search: {
          type: "custom",
          tokenizer: "standard",
          filter: ["lowercase"]
        }
      }
    }
  } do
    mappings dynamic: false do
      indexes :title,       type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :description, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :status,      type: :keyword
      indexes :due_date,    type: :date
    end
  end

  # --- Index serialization ---
  def as_indexed_json(_options = {})
    as_json(only: [:title, :description, :status, :due_date])
  end

  # --- Search method ---
  def self.search(query)
    return all if query.blank?

    __elasticsearch__.search({
      query: {
        bool: {
          should: [
            {
              multi_match: {
                query: query,
                fields: ['title^3', 'description', 'status'],
                fuzziness: 'AUTO'
              }
            },
            {
              wildcard: {
                title: { value: "*#{query.downcase}*" }
              }
            }
          ]
        }
      }
    })
  end

  # --- Associations ---
  belongs_to :user_as_contributor, class_name: "User", foreign_key: "contributor_id"
  belongs_to :project

  has_many :task_dependencies
  has_many :dependent_tasks, through: :task_dependencies, source: :dependent_task, class_name: "Task"
  has_many :inverse_task_dependencies, class_name: "TaskDependency", foreign_key: "dependent_task_id"
  has_many :prerequisite_tasks, through: :inverse_task_dependencies, source: :task, class_name: "Task"

  # --- Validations ---
  validates :title, :due_date, presence: true
  validate :cannot_complete_if_dependencies_incomplete, on: :update

  # --- Normalization ---
  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  # --- AASM States ---
  aasm column: 'status' do
    state :not_started, initial: true
    state :in_progress
    state :blocked
    state :completed

    event :start do
      transitions from: :not_started, to: :in_progress
    end

    event :block do
      transitions from: [:not_started, :in_progress], to: :blocked
    end

    event :unblock do
      transitions from: :blocked, to: :in_progress
    end

    event :complete do
      transitions from: [:in_progress, :blocked], to: :completed, guard: :dependencies_completed?
    end
  end

  # --- Callbacks ---
  after_commit :enqueue_dependency_resolution, if: :completed?
  after_commit :check_project_completion_after_task, on: :update, if: :saved_change_to_status?

  # --- Custom methods ---
  def dependencies_completed?
    prerequisite_tasks.all?(&:completed?)
  end

  private

  def check_project_completion_after_task
    return unless completed?
    incomplete_tasks = project.tasks.where.not(status: 'completed')
    ProjectCompletionWorker.perform_async(project.id) if incomplete_tasks.none?
  end

  def cannot_complete_if_dependencies_incomplete
    if status_changed? && status.to_sym == :completed && !dependencies_completed?
      errors.add(:status, "cannot be marked completed until all dependent tasks are completed")
    end
  end

  def enqueue_dependency_resolution
    DependencyResolutionWorker.perform_async(id)
  end
end
