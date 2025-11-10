class Project < ApplicationRecord
  include AASM

  include Searchable

  settings do
    mappings dynamic: false do
      indexes :title, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :description, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :status, type: :keyword
    end
  end

  # Define how data is serialized to Elasticsearch
  def as_indexed_json(options = {})
    as_json(only: [:title, :description, :status])
  end

  def self.search(query)
    super(query, ['title^3', 'description', 'status'])
  end

  # --- Associations ---
  has_many :tasks, dependent: :destroy
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"

  # --- Validations ---
  validates_presence_of :title

  # --- Normalization ---
  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  # --- AASM (state machine) ---
  aasm column: 'status' do
    state :active, initial: true
    state :inactive
    state :completed

    event :complete do
      transitions from: [:active], to: :completed
    end

    event :deactivate do
      transitions from: [:active, :completed], to: :inactive
    end
  end

  private

  def deactivate
    update(status: "inactive")
  end
end
