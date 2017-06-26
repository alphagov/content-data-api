class ReSeedQuestions < ActiveRecord::Migration[5.1]
  class Audit < ActiveRecord::Base
  end

  class Question < ActiveRecord::Base
  end

  class Response < ActiveRecord::Base
  end

  def up
    #   Drop audits, questions and responses then run seed

    Response.delete_all
    Question.delete_all
    Audit.delete_all

    Seeder.questions!
  end
end
