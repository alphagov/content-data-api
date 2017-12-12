RSpec.describe Clients::PublishingAPI do
  include GdsApi::TestHelpers::PublishingApiV2

  subject { Clients::PublishingAPI.new }

  describe "#all_content_items" do
    describe "multiple pages of 'en' content items" do
      let(:page_size) { 700 }

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

  describe "#fetch_latest_published" do
    let(:published) do
      {
        content_id: "id-123",
        title: "Published title",
        user_facing_version: 1,
        publication_state: "published",
      }
    end

    let(:draft) do
      published.merge(
        title: "Draft title",
        user_facing_version: 2,
        publication_state: "draft",
      )
    end

    before do
      publishing_api_has_item(draft)
      publishing_api_has_item(published, "version" => "1")
    end

    it "fetches the latest published edition" do
      result = subject.fetch_latest_published("id-123", "en")
      expect(result).to eq(published)
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

  # Everything below this line is deprecated.
  describe "#find_each" do
    it "loops through paged results from the gds publishing api" do
      subject.publishing_api = double
      page1 = { "results" => [{}], "pages" => 2, "current_page" => 1 }
      page2 = { "results" => [{}], "pages" => 2, "current_page" => 2 }

      expect(subject.publishing_api).to receive(:get_content_items).exactly(2).times.and_return(page1, page2)

      subject.find_each([]) {}
    end

    it "yields the results" do
      results = { "results" => [{ some: "thing" }], "pages" => 1, "current_page" => 1 }
      subject.publishing_api = double(:publishing_api, get_content_items: results)

      expect { |b| subject.find_each([], &b) }.to yield_with_args(hash_including(some: "thing"))
    end

    it "queries with the passed in options" do
      subject.publishing_api = double
      expected_query = {
        document_type: 'a_document_type',
        order: 'a_order',
        q: 'a_search_term',
        fields: %i[field_1 field_2]
      }
      result = { "results" => [{}], "pages" => 1, "current_page" => 1 }

      expect(subject.publishing_api).to receive(:get_content_items).with(hash_including(expected_query)).and_return(result)

      subject.find_each(%i[field_1 field_2], document_type: 'a_document_type', order: 'a_order', q: 'a_search_term') {}
    end

    it "makes a request for links when that option is passed in" do
      subject.publishing_api = double
      result = { "results" => [{ "content_id" => "the_id" }], "pages" => 1, "current_page" => 1 }

      allow(subject.publishing_api).to receive(:get_content_items).and_return(result)

      expect(subject).to receive(:links).with("the_id").and_return({})

      subject.find_each([], links: true) {}
    end
  end
end
