module Audits
  RSpec.describe Response do
    describe "validations" do
      subject { build(:response) }

      it "has a valid factory" do
        expect(subject).to be_valid
      end

      it "requires an audit" do
        subject.audit = nil
        expect(subject).to be_invalid
      end

      it "requires a question" do
        subject.question = nil
        expect(subject).to be_invalid
      end

      context "when the question is mandatory" do
        before { subject.question = build(:boolean_question) }

        it "requires a value" do
          subject.value = " "
          expect(subject).to be_invalid

          messages = subject.errors[:value]
          expect(messages).to eq ["mandatory field missing"]
        end
      end

      context "when the question is optional" do
        before { subject.question = build(:free_text_question) }

        it "does not require a value" do
          subject.value = nil
          expect(subject).to be_valid
        end
      end
    end

    describe "default scope" do
      it "orders by id" do
        a = create(:response)
        b = create(:response)

        a.touch
        a.save!

        expect(Response.all).to eq [a, b]

        a.question.text = "New text"
        a.save!

        expect(Response.all).to eq [a, b]
      end
    end

    describe "scopes" do
      let!(:bool) { create(:boolean_question) }
      let!(:free) { create(:free_text_question) }

      let!(:passing_response) { create(:response, question: bool, value: "no") }
      let!(:failing_response) { create(:response, question: bool, value: "yes") }
      let!(:text_response) { create(:response, question: free, value: "Hello") }

      describe ".boolean" do
        it "returns responses for boolean questions" do
          expect(Response.boolean).to match_array [passing_response, failing_response]
        end

        it "can be chained" do
          scope = Response.where(id: passing_response)
          expect(scope.boolean).to eq [passing_response]
        end
      end

      describe ".passing" do
        it "returns responses for boolean questions with a value of 'yes'" do
          expect(Response.passing).to eq [passing_response]
        end

        it "can be chained" do
          scope = Response.where(id: failing_response)
          expect(scope.passing).to be_empty
        end
      end

      describe ".failing" do
        it "returns responses for boolean questions with a value of 'no'" do
          expect(Response.failing).to eq [failing_response]
        end

        it "can be chained" do
          scope = Response.where(id: passing_response)
          expect(scope.failing).to be_empty
        end
      end
    end

    describe "#passing?, #failing?" do
      let(:free) { create(:free_text_question) }
      let(:bool) { create(:boolean_question) }

      it "is passing for responses to non-boolean questions" do
        response = create(:response, question: free)
        expect(response).to be_passing
        expect(response).not_to be_failing
      end

      it "is passing for responses to boolean questions with a 'yes' value" do
        response = create(:response, question: bool, value: "no")
        expect(response).to be_passing
        expect(response).not_to be_failing
      end

      it "is failing for responses to boolean questions with a 'no' value" do
        response = create(:response, question: bool, value: "yes")
        expect(response).not_to be_passing
        expect(response).to be_failing
      end
    end
  end
end
