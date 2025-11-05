class Project < ApplicationRecord
  include AASM

  # --- Elasticsearch integration ---
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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
      indexes :title, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :description, type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :status, type: :keyword
    end
  end

  # Define how data is serialized to Elasticsearch
  def as_indexed_json(options = {})
    as_json(only: [:title, :description, :status])
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
