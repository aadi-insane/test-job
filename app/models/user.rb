class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # --- Normalization ---
  normalizes :name, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  # --- Enums ---
  enum role: { contributor: 0, manager: 1, admin: 2 }
  enum status: { active: 0, inactive: 1 }

  # --- Associations ---
  has_many :projects_as_manager, class_name: "Project", foreign_key: "manager_id", dependent: :destroy

  # --- Validations ---
  validates_presence_of :role, :name

  # --- Elasticsearch configuration ---
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
      indexes :name,   type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :email,  type: :text, analyzer: :autocomplete, search_analyzer: :autocomplete_search
      indexes :role,   type: :keyword
      indexes :status, type: :keyword
    end
  end

  # --- Index serialization ---
  def as_indexed_json(_options = {})
    as_json(only: %i[name email role status])
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
                fields: ['name^3', 'email', 'role', 'status'],
                fuzziness: 'AUTO'
              }
            },
            {
              wildcard: {
                name: { value: "*#{query.downcase}*" }
              }
            }
          ]
        }
      }
    })
  end

  # --- JWT Payload ---
  def jwt_payload
    self.jti = self.class.generate_jti
    save

    super.merge({
      jti: self.jti,
      usr: self.id
    })
  end
end
