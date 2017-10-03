module Content
  RSpec.describe Importers::AllGoogleAnalyticsMetrics do
    describe "#run" do
      it "creates a job to import pageviews for content items" do
        content_items = [create(:content_item)]
        base_paths = content_items.map(&:base_path)
        expect(ImportPageviewsJob).to receive(:perform_async).with(base_paths)

        subject.run
      end

      it "creates a job per batch of content items" do
        create_list(:content_item, 2)
        subject.batch_size = 1

        expect(ImportPageviewsJob).to receive(:perform_async).twice

        subject.run
      end

      it "ignores nil basepaths" do
        create(:content_item, base_path: '/base-path')
        create(:content_item, base_path: nil)

        expect(ImportPageviewsJob).to receive(:perform_async).with(['/base-path'])

        subject.run
      end
    end
  end
end
