module Performance
  RSpec.describe Metrics::ZeroPageViews do
    subject { Metrics::ZeroPageViews }

    let!(:content_items) {
      [
        create(:content_item, one_month_page_views: 1),
        create(:content_item, one_month_page_views: 0),
        create(:content_item, one_month_page_views: 0)
      ]
    }

    it "returns the number of items with zero page views in the collection" do
      expect(subject.new(Content::Item.all).run).to eq(zero_page_views: { value: 2 })
    end
  end
end
