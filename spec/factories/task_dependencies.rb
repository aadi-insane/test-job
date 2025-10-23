FactoryBot.define do
  factory :task_dependency do
    task { nil }
    dependent_task { nil }
  end
end
