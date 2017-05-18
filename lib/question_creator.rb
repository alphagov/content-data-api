module QuestionCreator
  def self.create!
    return if Question.any?

    BooleanQuestion.create!(text: "Is the title clear in isolation?")
    BooleanQuestion.create!(text: "Is the description optimised?")
    BooleanQuestion.create!(text: "Is there a clear user need?")
    BooleanQuestion.create!(text: "Is the page out of date?")
    BooleanQuestion.create!(text: "Is the page the right format?")
    BooleanQuestion.create!(text: "Are there similar pages? (Merge pages)")
  end
end
