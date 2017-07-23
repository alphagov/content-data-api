module Content
  RSpec.describe Importers::AllGoogleAnalyticsMetrics do
    describe "#run" do
      it "creates a job to import pageviews for content items" do
        content_items = [create(:content_item)]
        expect(ImportPageviewsJob).to receive(:perform_later).with(content_items)

        subject.run
      end

      it "creates a job per batch of content items" do
        create_list(:content_item, 2)
        subject.batch_size = 1

        expect(ImportPageviewsJob).to receive(:perform_later).twice

        subject.run
      end
    end
  end
end
