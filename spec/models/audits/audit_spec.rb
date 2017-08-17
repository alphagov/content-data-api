module Audits
  RSpec.describe Audit do
    subject { build(:audit) }

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

    describe "callbacks" do
      it "precomputes the content_item's report row after saving" do
        expect { subject.save! }.to change(ReportRow, :count).by(1)
        expect { subject.save! }.not_to change(ReportRow, :count)
      end
    end

    describe "scopes" do
      let!(:passing_audit) { create(:passing_audit) }
      let!(:failing_audit) { create(:failing_audit) }

      describe ".passing" do
        it "returns audits where all boolean responses are 'no'" do
          expect(Audit.passing).to eq [passing_audit]
        end

        it "can be chained" do
          scope = Audit.where(id: failing_audit)
          expect(scope.passing).to be_empty
        end
      end

      describe ".failing" do
        it "returns audits where any one boolean response is 'yes'" do
          expect(Audit.failing).to eq [failing_audit]
        end

        it "can be chained" do
          scope = Audit.where(id: passing_audit)
          expect(scope.failing).to be_empty
        end
      end
    end

    describe "#passing?, #failing?" do
      it "is passing if all responses are passing" do
        audit = create(:passing_audit)

        expect(audit).to be_passing
        expect(audit).not_to be_failing
      end

      it "is failing if any response is failing" do
        audit = create(:failing_audit)

        expect(audit).not_to be_passing
        expect(audit).to be_failing
      end
    end
  end
end
