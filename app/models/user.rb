class User < ApplicationRecord
  validates_presence_of :name, :email, :role
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  
  has_secure_password

  normalizes :name, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  enum role: { contributer: 0, manager: 1, admin: 2 }

  has_many :projects_as_manager, class_name: "Project", foreign_key: "manager_id"
  # belongs_to :task, as: :contributer
  belongs_to :task, foreign_key: "contributer_id"
end

# class User < ApplicationRecord
#   validates_presence_of :name, :email, :role
#   validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  
#   has_secure_password

#   normalizes :name, with: ->(value) { value.split.map(&:capitalize).join(' ') }

#   enum role: { contributer: 0, manager: 1, admin: 2 }

#   has_many :projects_as_manager, class_name: "Project", foreign_key: "manager_id"
#   belongs_to :task, as: :contributer
# end


