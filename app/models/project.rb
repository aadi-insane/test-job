class Project < ApplicationRecord
  include AASM

  # has_rich_text :content
  has_many :tasks, dependent: :destroy
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"

  validates_presence_of :title

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

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
