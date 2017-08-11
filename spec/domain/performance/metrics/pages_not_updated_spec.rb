module Performance
  RSpec.describe Metrics::PagesNotUpdated do
    subject { Metrics::PagesNotUpdated }
    let!(:content_items) {
      [
        create(:content_item, public_updated_at: 7.months.ago),
        create(:content_item, public_updated_at: Date.today)
      ]
    }

    it "returns the number of items with zero page views in the collection" do
      expect(subject.new(Content::Item.all).run).to eq(pages_not_updated: { value: 1 })
    end
  end
end
