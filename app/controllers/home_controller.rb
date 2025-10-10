class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    if current_user.admin?
      task_counts = Task.group(:contributor_id).count
      project_counts = Project.group(:manager_id).count

      user_ids = (task_counts.keys + project_counts.keys).uniq
      users_by_id = User.where(id: user_ids).pluck(:id, :name).to_h

      @task_data = task_counts.transform_keys { |id| users_by_id[id] || "Unknown" }
      @project_data = project_counts.transform_keys { |id| users_by_id[id] || "Unknown" }
    end
  end
end
