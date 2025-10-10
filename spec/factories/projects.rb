FactoryBot.define do
  factory :project do
    title { Faker::Book.title }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    status { 'active' }
    manager_id { FactoryBot.create(:manager).id }
  end
end
