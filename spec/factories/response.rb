FactoryGirl.define do
  factory :response do
    audit
    question factory: :boolean_question
    value "true"
  end
end
