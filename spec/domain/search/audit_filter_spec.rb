RSpec.describe Search::AuditFilter do
  subject { described_class }

  it "raises for an unrecognised audit status" do
    expect { subject.new(:invalid_audit_status) }
      .to raise_error(AuditStatusError, /unrecognised audit status/)
  end

  it "does not raise exception with nil values" do
    expect { subject.new(nil) }
      .to_not raise_error
  end

  it "symbolises the value" do
    expect(subject.new("audited").status).to eq(:audited)
  end

  describe "#apply" do
    let(:content_item_audited) { create :content_item }
    let(:content_item_non_audited) { create :content_item }

    before { create(:audit, content_item: content_item_audited) }

    it "can filter audited content items" do
      results = subject.new(:audited).apply(ContentItem.all)

      expect(results).to match_array([content_item_audited])
    end

    it "can filter non-audited content items" do
      results = subject.new(:non_audited).apply(ContentItem.all)

      expect(results).to match_array([content_item_non_audited])
    end
  end
end
