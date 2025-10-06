class Project < ApplicationRecord
  validates_presence_of :title

  enum status: { active: 0, in_active: 1, completed: 2 }
  
  has_many :tasks
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

end
