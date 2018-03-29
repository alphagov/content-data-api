RSpec.describe Clients::PublishingAPI do
  include GdsApi::TestHelpers::PublishingApiV2

  subject { Clients::PublishingAPI.new }

  describe "#all_content_items" do
    describe "multiple pages of 'en' content items" do
      let(:page_size) { 50 }

      let(:content_ids) { (page_size + 1).times.map { |i| "id-#{i}" } }

      it "returns all the content ids and locales" do
        editions = content_ids.map { |id| { "content_id" => id, "locale" => "en" } }

        pages = editions.each_slice(page_size).map do |page|
          {
            "results" => page,
          }
        end

        allow_any_instance_of(GdsApi::PublishingApiV2)
          .to receive(:get_paged_editions)
            .with(
              fields: %[content_id locale],
              states: %w[published],
              per_page: page_size,
            )
            .and_return(pages)

        result = subject.fetch_all(%[content_id locale])
        expect(result).to eq(
          editions.map(&:deep_symbolize_keys)
        )
      end
    end
  end

  describe "#fetch" do
    let(:content_item) { { content_id: "id-123", title: "title" } }

    before do
      publishing_api_has_item(content_item)
    end

    it "fetches a content item by content id" do
      result = subject.fetch("id-123", locale: "en")
      expect(result).to eq(content_item)
    end
  end

  describe "#links" do
    let(:links) { { organisation: ["org-123"] } }

    before do
      publishing_api_has_links(content_id: "id-123", links: links)
    end

    it "gets the links for a content item" do
      result = subject.links("id-123")
      expect(result).to eq(links)
    end
  end
end
