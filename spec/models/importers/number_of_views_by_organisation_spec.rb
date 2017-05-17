RSpec.describe Importers::NumberOfViewsByOrganisation do
  describe "#run" do
    let(:organisation) { create(:organisation, slug: "the-slug") }

    it "creates a job to import pageviews for content items" do
      content_items = [create(:content_item)]
      organisation.content_items << content_items

      expect(ImportPageviewsJob).to receive(:perform_later).with(content_items)

      subject.run("the-slug")
    end

    it "creates a job per batch of content items" do
      organisation.content_items << create_list(:content_item, 2)
      subject.batch_size = 1

      expect(ImportPageviewsJob).to receive(:perform_later).twice

      subject.run("the-slug")
    end
  end
end
