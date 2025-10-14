class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  normalizes :name, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  enum role: { contributor: 0, manager: 1, admin: 2 }

  has_many :projects_as_manager, class_name: "Project", foreign_key: "manager_id", dependent: :destroy

  validates_presence_of :role, :name

  # before_create :ensure_jti

  # private
  #   def ensure_jti
  #     self.jti ||= SecureRandom.uuid
  #   end


  # http://stackoverflow.com/questions/50637167/rails-devise-jwt-gem-is-not-updating-jti-in-the-user-after-login FOLLOWING CODE

  def jwt_payload
    self.jti = self.class.generate_jti
    self.save

    # super isn't doing anything useful, but if the gem updates i'll want it to be safe
    super.merge({
      jti: self.jti,
      usr: self.id,
    })
  end
end
