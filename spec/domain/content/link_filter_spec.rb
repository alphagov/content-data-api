RSpec.describe Content::LinkFilter do
  subject { described_class }
  it "raises an error if constructing a filter with source and target" do
    expect {
      subject.new(
        link_type: "organisations",
        source_ids: "id1",
        target_ids: "org1",
      )
    }.to raise_error(LinkFilterError, /source or target/)
  end

  describe "#apply" do
    let!(:content_item1) { create(:content_item, content_id: "sid1") }
    let!(:content_item2) { create(:content_item, content_id: "tid1") }
    let!(:link) { create(:link, link_type: "organisations", source_content_id: "sid1", target_content_id: "tid1") }

    it "returns the links filter by source_ids" do
      scope = Content::Item.all
      filter = subject.new(link_type: "organisations", source_ids: "sid1")

      expect(filter.apply(scope)).to match_array([content_item2])
    end

    it "returns the links filter by target ids" do
      scope = Content::Item.all
      filter = subject.new(link_type: "organisations", target_ids: "tid1")

      expect(filter.apply(scope)).to match_array([content_item1])
    end
  end
end
