FactoryBot.define do
  factory :contributor, class: User do
    # name        { Faker::Name.name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    role        { 'contributor'}
  end
  factory :manager, class: User do
    # name        { Faker::Name.name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    role        { 'manager' }
  end
  factory :admin, class: User do
    # name        { Faker::Name.name }
    email       { Faker::Internet.email }
    password    { Faker::Internet.password }
    role        { 'admin' }
  end
end
