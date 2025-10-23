class TaskDependency < ApplicationRecord
  belongs_to :task
  belongs_to :dependent_task, class_name: "Task"
end
