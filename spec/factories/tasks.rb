FactoryBot.define do
  factory :task do
    title { "Test Task" }
    due_date { 1.week.from_now }
    status { :not_started }
    user_as_contributor { create(:user) }
    project { create(:project) }

    trait :completed do
      status { :completed }
    end

    trait :in_progress do
      status { :in_progress }
    end
  end
end
