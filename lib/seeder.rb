module Seeder
  def self.seed!
    questions!
    user!
  end

  def self.questions!
    return if Question.any?

    BooleanQuestion.create!(text: "Title")
    BooleanQuestion.create!(text: "Summary")
    BooleanQuestion.create!(text: "Page detail")
    BooleanQuestion.create!(text: "Attachments")
    BooleanQuestion.create!(text: "Document type")
    BooleanQuestion.create!(text: "Is the content out of date?")
    BooleanQuestion.create!(text: "Should the content be removed?")
    BooleanQuestion.create!(text: "Is this content very similar to other pages?")

    FreeTextQuestion.create!(text: "URLs of similar pages")
    FreeTextQuestion.create!(text: "Notes")
  end

  def self.user!
    return if User.any?

    User.create!(
      uid: "user-1",
      name: "Test User",
      organisation_slug: "government-digital-service",
      permissions: %w(inventory_management),
    )
  end
end
