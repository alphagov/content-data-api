require 'rails_helper'

RSpec.describe ContentItemsService do
  include GdsApi::TestHelpers::PublishingApiV2

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
end
