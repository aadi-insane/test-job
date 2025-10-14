FactoryBot.define do
  factory :task do
    title { Faker::Book.title }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    status { 'not_started' }
    contributor_id { FactoryBot.create(:contributor).id }
    project_id { FactoryBot.create(:project).id }
  end
end
