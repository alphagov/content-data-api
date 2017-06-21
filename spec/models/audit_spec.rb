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

  describe "scopes" do
    let!(:passing_audit) { FactoryGirl.create(:audit) }
    let!(:failing_audit) { FactoryGirl.create(:audit) }

    before do
      bool = FactoryGirl.create(:boolean_question)
      free = FactoryGirl.create(:free_text_question)

      FactoryGirl.create(:response, audit: passing_audit, question: bool, value: "yes")
      FactoryGirl.create(:response, audit: passing_audit, question: bool, value: "yes")
      FactoryGirl.create(:response, audit: passing_audit, question: free, value: "Hello")

      FactoryGirl.create(:response, audit: failing_audit, question: bool, value: "yes")
      FactoryGirl.create(:response, audit: failing_audit, question: bool, value: "no")
      FactoryGirl.create(:response, audit: failing_audit, question: free, value: "Hello")
    end

    describe ".passing" do
      it "returns audits where all boolean responses are 'yes'" do
        expect(Audit.passing).to eq [passing_audit]
      end

      it "can be chained" do
        scope = Audit.where(id: failing_audit)
        expect(scope.passing).to be_empty
      end
    end

    describe ".failing" do
      it "returns audits where any one boolean response is 'no'" do
        expect(Audit.failing).to eq [failing_audit]
      end

      it "can be chained" do
        scope = Audit.where(id: passing_audit)
        expect(scope.failing).to be_empty
      end
    end
  end
end
