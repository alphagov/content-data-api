module Seeder
  def self.seed!
    questions!
  end

  def self.questions!
    return if Audits::Question.any?

    Audits::BooleanQuestion.create!(text: "Title")
    Audits::BooleanQuestion.create!(text: "Summary")
    Audits::BooleanQuestion.create!(text: "Page detail")
    Audits::BooleanQuestion.create!(text: "Attachments")
    Audits::BooleanQuestion.create!(text: "Document type")
    Audits::BooleanQuestion.create!(text: "Is the content out of date?")
    Audits::BooleanQuestion.create!(text: "Should the content be removed?")
    Audits::BooleanQuestion.create!(text: "Is this content very similar to other pages?")

    Audits::FreeTextQuestion.create!(text: "URLs of similar pages")
    Audits::FreeTextQuestion.create!(text: "Notes")
  end
end
