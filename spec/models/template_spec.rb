RSpec.describe Template do
  describe "#questions" do
    it "returns an ordered list of questions" do
      q = subject.questions

      expect(q.first.text).to eq("Is the title clear in isolation?")
      expect(q.last.text).to eq("Notes")
    end

    context "when no questions exist" do
      before { Question.destroy_all }
      after { QuestionCreator.create! }

      it "provides a helpful error" do
        expect { subject.questions }.to raise_error(/rake db:seed/)
      end
    end
  end

  describe "#mandatory?" do
    let(:q1) { FactoryGirl.build(:boolean_question) }
    let(:q2) { FactoryGirl.build(:free_text_question) }

    it "returns true for boolean questions" do
      expect(subject.mandatory?(q1)).to eq(true)
    end

    it "returns false for free text questions" do
      expect(subject.mandatory?(q2)).to eq(false)
    end
  end
end
