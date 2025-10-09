class Task < ApplicationRecord
  include AASM

  belongs_to :user_as_contributor, class_name: "User", foreign_key: "contributor_id"
  belongs_to :project

  validates :title, presence: true
  validate :valid_status_transition, on: :update

  normalizes :title, with: ->(value) { value.split.map(&:capitalize).join(' ') }

  aasm column: 'status', enum: true do
    state :not_started, initial: true
    state :in_progress
    state :completed

    event :start do
      transitions from: :not_started, to: :in_progress
    end

    event :complete do
      transitions from: [:not_started, :in_progress], to: :completed, after: :check_project_completion
    end
  end

  private
    # def check_project_completion
    #   if project.tasks.where.not(status: "completed").none?
    #     project.update(status: "completed")
    #   end
    # end

    def check_project_completion
      if project.tasks.where.not(status: 'completed').none? && project.may_complete?
        project.complete!
        project.deactivate! if project.may_deactivate?
      end
    end



    def valid_status_transition
      return unless status_changed?

      from = status_was&.to_sym
      to = status&.to_sym

      case [from, to]
      when [:not_started, :in_progress]
        true
      when [:not_started, :completed]
        true
      when [:in_progress, :completed]
        true
      when [:in_progress, :in_progress]
        true
      when [:not_started, :not_started]
        true
      when [:completed, :completed]
        true
      else
        errors.add(:status, "transition from #{from} to #{to} is not allowed")
      end
    end
end
