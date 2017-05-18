class Template
  attr_accessor :audit

  def initialize(audit)
    self.audit = audit
  end

  def questions
    fail "You need to run rake db:seed to create the questions" if Question.none?
    Question.all.to_a
  end

  def mandatory?(_question)
    true
  end
end
