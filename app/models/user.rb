class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Searchable

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
  settings do
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

  def self.search(query)
    super(query, ['name^3', 'email', 'role', 'status'])
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
