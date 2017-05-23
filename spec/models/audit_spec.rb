RSpec.describe Audit do
  subject { FactoryGirl.build(:audit) }

  describe "associations" do
    it "builds responses when assigning questions" do
      q1 = FactoryGirl.build(:boolean_question)
      q2 = FactoryGirl.build(:boolean_question)

      subject.questions = [q1, q2]

      expect(subject.responses.size).to eq(2)
      first = subject.responses.first

      expect(first.audit).to eq(subject)
      expect(first.question).to eq(q1)
    end
  end

  describe "validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a content_item" do
      subject.content_item = nil
      expect(subject).to be_invalid
    end

    it "requires a user" do
      subject.user = nil
      expect(subject).to be_invalid
    end
  end
end
