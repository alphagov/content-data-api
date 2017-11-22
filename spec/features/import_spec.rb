require "rails_helper"

RSpec.feature "Import a single content item", type: :feature do
  include GdsApi::TestHelpers::PublishingApiV2

  it "creates jobs to import a single content items" do
    content_item = build(
      :content_item,
      content_id: "id-123",
      title: "title",
    ).as_json.merge(
      publication_state: "published",
    ).deep_symbolize_keys

    publishing_api_has_links(content_id: content_item[:content_id], links: { organisation: ["org-123"] })
    publishing_api_has_item(content_item)

    expect { Content::ImportItemJob.new.perform("id-123", "en") }
      .to change(Content::Item, :count).by(1)
      .and change(Content::Link, :count).by(1)
  end

  describe "a content item that exists as only a draft" do
    before do
      content_item = build(
        :content_item,
        content_id: "id-123",
        title: "title",
      ).as_json.merge(
        publication_state: "draft",
        user_facing_version: 1,
      ).deep_symbolize_keys

      publishing_api_has_links(content_id: content_item[:content_id], links: {})
      publishing_api_has_item(content_item)
    end

    it "does not import anything" do
      expect { Content::ImportItemJob.new.perform("id-123", "en") }
        .to change(Content::Item, :count).by(0)
        .and change(Content::Link, :count).by(0)

      expect(Content::Item.find_by(content_id: "id-123")).to be_nil
    end
  end
end
