require "rails_helper"

RSpec.describe "content_items/show.json.jbuilder", type: :view do
  it "renders CONTENT_ITEM in JSON format" do
    content_item = create(
      :content_item,
      content_id: "123",
      base_path: "/the/path/to/the/item",
      title: "The title for this content item",
      document_type: "html",
      description: "This is the description for the content item",
      unique_page_views: "1000",
      number_of_pdfs: "2"
    )
    assign(:content_item, content_item)
    render

    response = JSON.parse(rendered)
    expect(response).to include(
      "content_id" => "123",
      "base_path" => "/the/path/to/the/item",
      "title" => "The title for this content item",
      "document_type" => "html",
      "description" => "This is the description for the content item",
      "unique_page_views" => 1000,
      "number_of_pdfs" => 2
    )
  end
end
