class UpdateTypeColumnForQuestions < ActiveRecord::Migration[5.1]
  class Question < ActiveRecord::Base
  end

  def up
    Question.connection.execute("UPDATE questions SET type = 'Audits::FreeTextQuestion' WHERE type = 'FreeTextQuestion';")
    Question.connection.execute("UPDATE questions SET type = 'Audits::BooleanQuestion' WHERE type = 'BooleanQuestion';")
  end

  def down
    Question.connection.execute("UPDATE questions SET type = 'FreeTextQuestion' WHERE type = 'Audits::FreeTextQuestion';")
    Question.connection.execute("UPDATE questions SET type = 'BooleanQuestion' WHERE type = 'Audits::BooleanQuestion';")
  end
end
