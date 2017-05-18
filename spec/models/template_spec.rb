RSpec.describe Template do
  let(:audit) { FactoryGirl.build(:audit) }
  subject { described_class.new(audit) }

  describe "#questions" do
    it "returns an ordered list of questions" do
      q = subject.questions

      expect(q.first.text).to eq("Is the title clear in isolation?")
      expect(q.last.text).to eq("Are there similar pages? (Merge pages)")
    end

    context "when no questions exist" do
      before { Question.destroy_all }
      after { QuestionCreator.create! }

      it "provides a helpful error" do
        expect { subject.questions }.to raise_error(/rake db:seed/)
      end
    end
  end
end
