module Audits
  class Template
    def questions
      fail "You need to run rake db:seed to create the questions" if Question.none?
      Question.all.order(:id).to_a
    end

    def mandatory?(question)
      question.is_a?(BooleanQuestion)
    end
  end
end
