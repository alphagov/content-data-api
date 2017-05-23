require_relative "../../app/models/question/boolean_question"
require_relative "../../app/models/question/free_text_question"

FactoryGirl.define do
  factory :boolean_question, class: BooleanQuestion do
    sequence(:text) { |i| "BooleanQuestion #{i}" }
  end

  factory :free_text_question, class: FreeTextQuestion do
    sequence(:text) { |i| "FreeTextQuestion #{i}" }
  end
end
