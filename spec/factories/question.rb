FactoryGirl.define do
  factory :boolean_question, class: BooleanQuestion do
    sequence(:text) { |i| "BooleanQuestion #{i}" }
  end
end
