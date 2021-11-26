FactoryBot.define do
  factory :article do
    title { Faker::String.random(length: 15) }
    body { Faker::String.random }
    user
  end
end
