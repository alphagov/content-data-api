module Seeder
  def self.seed!
    questions!
    user!
  end

  def self.questions!
    return if Question.any?

    BooleanQuestion.create!(text: "Is the title clear in isolation?")
    BooleanQuestion.create!(text: "Is the description optimised?")
    BooleanQuestion.create!(text: "Is there a clear user need?")
    BooleanQuestion.create!(text: "Is the page out of date?")
    BooleanQuestion.create!(text: "Is the page the right format?")
    BooleanQuestion.create!(text: "Are there similar pages? (Merge pages)")

    FreeTextQuestion.create!(text: "Redirect or combine with URL")
    FreeTextQuestion.create!(text: "Notes")
  end

  def self.user!
    return if User.any?

    User.create!(
      uid: "user-1",
      name: "Test User",
      organisation_slug: "government-digital-service",
    )
  end
end
