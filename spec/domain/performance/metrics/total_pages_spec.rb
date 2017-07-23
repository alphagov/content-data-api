module Performance
  RSpec.describe Metrics::TotalPages do
    subject { Metrics::TotalPages }

    let(:content_items) { build_list(:content_item, 5) }

    it "returns the number of items in the collection" do
      expect(subject.new(content_items).run).to eq(total_pages: { value: 5 })
    end
  end
end
