require 'rails_helper'

RSpec.describe Importers::NumberOfViewsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }
    let!(:content_item_first) { create(:content_item, base_path: 'the-link/first', organisation: organisation) }
    let!(:content_item_second) { create(:content_item, base_path: 'the-link/second', organisation: organisation) }

    before do
      allow_any_instance_of(GoogleAnalyticsService).to receive(:page_views).and_return(
        [
          {
            base_path: 'the-link/first',
            page_views: 3,
          },
          {
            base_path: 'the-link/second',
            page_views: 2,
          },
        ]
      )
    end

    it "updates the number of views for all content items" do
      organisation.content_items = [content_item_first, content_item_second]

      subject.run('the-slug')

      content_item_one = ContentItem.find_by(base_path: 'the-link/first')
      content_item_two = ContentItem.find_by(base_path: 'the-link/second')

      expect(content_item_one.unique_page_views).to eq(3)
      expect(content_item_two.unique_page_views).to eq(2)
    end
  end
end
