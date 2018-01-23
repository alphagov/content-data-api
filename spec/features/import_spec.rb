require "rails_helper"

RSpec.feature "Import a single content item", type: :feature do
  include GdsApi::TestHelpers::PublishingApiV2

  it "creates jobs to import a single content items" do
    publishing_api_has_links(content_id: "id-123", links: { organisation: ["org-123"] })
    publishing_api_has_item(build(:content_item, content_id: "id-123", title: "title"))

    expect { ImportItemJob.new.perform("id-123", "en", "10") }
      .to change(Item, :count).by(1)
      .and change(Link, :count).by(1)
  end
end
