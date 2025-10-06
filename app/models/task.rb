class Task < ApplicationRecord
  belongs_to :project
  enum status: { not_started: 0, in_progress: 1, completed: 2 }

  has_one :user_as_contributer, class_name: "User", foreign_key: "contributer_id"

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }
end

