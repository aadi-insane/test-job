class Project < ApplicationRecord
  include AASM

  has_many :tasks, dependent: :destroy
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"

  validates_presence_of :title

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  aasm column: 'status', enum: true do
    state :active, initial: true
    state :inactive
    state :completed

    event :complete do
      transitions from: [:active], to: :completed, after: :deactivate
    end
  end

  private

  def deactivate
    update(status: "inactive")
  end
end
