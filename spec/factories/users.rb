FactoryBot.define do
  factory :user, class: User do
    name        { Faker::Name.name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    role        { 'contributor' }
  end

  factory :contributor, parent: :user do
    role { 'contributor' }
  end

  factory :manager, parent: :user do
    role { 'manager' }
  end

  factory :admin, parent: :user do
    role { 'admin' }
  end
end
