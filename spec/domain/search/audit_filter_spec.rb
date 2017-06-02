RSpec.describe Search::AuditFilter do
  it "symbolises the identifier" do
    filter = described_class.new("identifier", "name")
    expect(filter.identifier).to eq(:identifier)
  end

  describe "#apply" do
    let(:content_item_audited) { create :content_item }
    let(:content_item_non_audited) { create :content_item }

    before { create(:audit, content_item: content_item_audited) }

    it "can filter audited content items" do
      filter = described_class.find(:audited)
      results = filter.apply(ContentItem.all)

      expect(results).to match_array([content_item_audited])
    end

    it "can filter non-audited content items" do
      filter = described_class.find(:non_audited)
      results = filter.apply(ContentItem.all)

      expect(results).to match_array([content_item_non_audited])
    end
  end
end
