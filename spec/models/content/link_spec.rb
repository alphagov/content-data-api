RSpec.describe Content::Link do
  describe "callbacks" do
    let(:content_item) { build(:content_item) }
    subject { build(:link, source: content_item) }

    it "precomputes the content_item's report row after saving" do
      expect { subject.save! }.to change(Audits::ReportRow, :count).by(1)
      expect { subject.save! }.not_to change(Audits::ReportRow, :count)
    end
  end
end
