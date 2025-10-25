class Task < ApplicationRecord
  include AASM

  belongs_to :user_as_contributor, class_name: "User", foreign_key: "contributor_id"
  belongs_to :project

  validates :title, :due_date, presence: true
  validate :cannot_complete_if_dependencies_incomplete, on: :update
  validate :assignee_must_be_active

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  # Ye Dependent Tasks k liye
  has_many :task_dependencies
  has_many :dependent_tasks, through: :task_dependencies, source: :dependent_task, class_name: "Task"

  # Ye Prerequisite Tasks k liye
  has_many :inverse_task_dependencies, class_name: "TaskDependency", foreign_key: "dependent_task_id"
  has_many :prerequisite_tasks, through: :inverse_task_dependencies, source: :task, class_name: "Task"

  after_commit :enqueue_dependency_resolution, if: :completed?
  after_commit :check_project_completion_after_task, on: :update, if: :saved_change_to_status?

  def dependencies_completed?
    prerequisite_tasks.all? { |t| t.completed? }
  end

  aasm column: 'status' do
    state :not_started, initial: true
    state :in_progress
    state :completed

    event :start do
      transitions from: :not_started, to: :in_progress
    end

    event :complete do
      transitions from: [:in_progress], to: :completed, guard: :dependencies_completed?
    end
  end

  private
    def check_project_completion_after_task
      return unless completed?
      incomplete_tasks = project.tasks.where.not(status: 'completed')
      if incomplete_tasks.none?
        ProjectCompletionWorker.perform_async(project.id)
      end
    end

    def cannot_complete_if_dependencies_incomplete
      if status_changed? && status.to_sym == :completed && !dependencies_completed?
        errors.add(:status, "cannot be marked completed until all dependent tasks are completed")
      end
    end

    def assignee_must_be_active
      if user_as_contributor && !user_as_contributor.active?
        errors.add(:contributor_id, "cannot assign task to inactive user")
      end
    end

    def enqueue_dependency_resolution
      DependencyResolutionWorker.perform_async(id)
    end
end
