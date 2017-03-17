require "rails_helper"

RSpec.describe "groups/show.json.jbuilder", type: :view do
  it "renders GROUP in JSON format" do
    group = create :group, id: 18, slug: 'the-slug', name: 'a-name', group_type: 'type'
    assign(:group, group)
    render

    response = JSON.parse(rendered)
    expect(response).to include(
      "id" => 18,
      "slug" => "the-slug",
      "name" => "a-name",
      "group_type" => "type",
      "url" => "http://test.host/groups/18.json"
    )
  end
end
