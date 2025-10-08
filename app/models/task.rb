class Task < ApplicationRecord
  validates_presence_of :title

  enum status: { not_started: 0, in_progress: 1, completed: 2 }

  belongs_to :user_as_contributor, class_name: "User", foreign_key: "contributor_id"
  belongs_to :project

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }
end

