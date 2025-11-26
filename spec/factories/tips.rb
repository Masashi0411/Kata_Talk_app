# spec/factories/tips.rb
FactoryBot.define do
  factory :tip do
    title { "Test TIP" }
    description { "Test description" }
    practice_description { "Test practice" }
    content { "Test content" }   # ← schemaの必須項目
    scheduled_date { Date.current }  # ← 必須
    day_of_month { 1 }
  end
end
