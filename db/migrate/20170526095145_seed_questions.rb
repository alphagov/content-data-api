class SeedQuestions < ActiveRecord::Migration[5.0]
  def up
    Seeder.questions!
  end

  def down
    Question.delete_all
  end
end
