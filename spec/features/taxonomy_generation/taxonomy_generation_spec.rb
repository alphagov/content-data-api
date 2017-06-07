require "rails_helper"

RSpec.feature "Taxonomy generation", type: :feature do
  it "has an index page" do
    taxonomy_project = create(:taxonomy_project, name: "Project Foo")
    create(:taxonomy_todo, taxonomy_project: taxonomy_project, content_item: create(:content_item, title: "Title Foo"))
    create(:taxonomy_todo, taxonomy_project: taxonomy_project, content_item: create(:content_item, title: "Title Bar"))

    visit taxonomy_projects_path

    click_on "Project Foo"

    expect(page).to have_content "Project Foo"
    expect(page).to have_content "Title Foo"
    expect(page).to have_content "Title Bar"
  end
end
