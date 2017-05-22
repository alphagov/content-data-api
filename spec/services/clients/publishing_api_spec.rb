RSpec.describe Clients::PublishingAPI do
  include GdsApi::TestHelpers::PublishingApiV2

  subject { Clients::PublishingAPI.new }

  describe "#content_ids" do
    let(:content_ids) { 1001.times.map { |i| "id-#{i}" } }

    before do
      1.upto(2) do |page|
        publishing_api_has_content(
          content_ids.map { |id| { content_id: id } },
          fields: %w(content_id),
          states: %w(published),
          page: page,
          per_page: 1_000,
        )
      end
    end

    it "returns all the content ids" do
      result = subject.content_ids
      expect(result).to eq(content_ids)
    end
  end

  describe "#fetch" do
    let(:content_item) { { content_id: "id-123", title: "title" } }

    before do
      publishing_api_has_item(content_item)
    end

    it "fetches a content item by content id" do
      result = subject.fetch("id-123")
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

  # Everything below this line is deprecated.
  describe "#find_each" do
    it "loops through paged results from the gds publishing api" do
      subject.deprecated_publishing_api = double
      page_1 = { "results" => [{}], "pages" => 2, "current_page" => 1 }
      page_2 = { "results" => [{}], "pages" => 2, "current_page" => 2 }

      expect(subject.deprecated_publishing_api).to receive(:get_content_items).exactly(2).times.and_return(page_1, page_2)

      subject.find_each([]) {}
    end

    it "yields the results" do
      results = { "results" => [{ some: "thing" }], "pages" => 1, "current_page" => 1 }
      subject.deprecated_publishing_api = double(:publishing_api, get_content_items: results)

      expect { |b| subject.find_each([], &b) }.to yield_with_args(hash_including(some: "thing"))
    end

    it "queries with the passed in options" do
      subject.deprecated_publishing_api = double
      expected_query = {
        document_type: 'a_document_type',
        order: 'a_order',
        q: 'a_search_term',
        fields: [:field_1, :field_2]
      }
      result = { "results" => [{}], "pages" => 1, "current_page" => 1 }

      expect(subject.deprecated_publishing_api).to receive(:get_content_items).with(hash_including(expected_query)).and_return(result)

      subject.find_each([:field_1, :field_2], document_type: 'a_document_type', order: 'a_order', q: 'a_search_term') {}
    end

    it "makes a request for links when that option is passed in" do
      subject.deprecated_publishing_api = double
      result = { "results" => [{ "content_id" => "the_id" }], "pages" => 1, "current_page" => 1 }

      allow(subject.deprecated_publishing_api).to receive(:get_content_items).and_return(result)

      expect(subject).to receive(:deprecated_links).with("the_id").and_return({})

      subject.find_each([], links: true) {}
    end
  end
end
