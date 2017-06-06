RSpec.describe "groups/index.json.jbuilder", type: :view do
  it "renders JSON with all the Groups and number of Content IDs" do
    group1 = create :group, :with_two_content_items, id: 1, slug: "slug-1"
    group2 = create :group, :with_one_content_item, id: 2, slug: "slug-2"
    assign :groups, [group1, group2]
    render

    json = JSON.parse(rendered).deep_symbolize_keys
    expect(json).to match(
      groups: [
        { slug: 'slug-1', total: 2 },
        { slug: 'slug-2', total: 1 }
      ]
    )
  end
end
