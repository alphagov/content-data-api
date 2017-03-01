require 'rails_helper'

RSpec.describe Importers::NumberOfViewsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }
    let!(:content_item_first) { create(:content_item, base_path: 'the-link/first', organisations: [organisation]) }
    let!(:content_item_second) { create(:content_item, base_path: 'the-link/second', organisations: [organisation]) }

    it "updates the number of views for all content items" do
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

      stub_const("Importers::NumberOfViewsByOrganisation::BATCH_SIZE", 1)

      subject.run('the-slug')

      content_item_one = ContentItem.find_by(base_path: 'the-link/first')
      content_item_two = ContentItem.find_by(base_path: 'the-link/second')

      expect(content_item_one.unique_page_views).to eq(3)
      expect(content_item_two.unique_page_views).to eq(2)
    end

    context "performs the request to google api in batches" do
      it "makes two requests when the batch size is one" do
        expect_any_instance_of(GoogleAnalyticsService).to receive(:page_views).twice.and_return([])

        stub_const("Importers::NumberOfViewsByOrganisation::BATCH_SIZE", 1)

        subject.run('the-slug')
      end

      it "makes one request when the batch size is two" do
        expect_any_instance_of(GoogleAnalyticsService).to receive(:page_views).once.and_return([])

        stub_const("Importers::NumberOfViewsByOrganisation::BATCH_SIZE", 2)

        subject.run('the-slug')
      end
    end
  end
end
