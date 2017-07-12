require "rails_helper"

RSpec.feature "Taxonomy generation", type: :feature do
  scenario "User creates a project" do
    when_i_visit_the_projects_page
    and_i_click_on_the_new_project_button
    and_i_submit_a_new_project
    then_i_should_see_the_project
  end

  def when_i_visit_the_projects_page
    visit taxonomy_projects_path
  end

  def and_i_click_on_the_new_project_button
    click_link "New project"
  end

  def and_i_submit_a_new_project
    create(:content_item, title: "Page Foo", content_id: "5d18871a-6d63-49aa-9c60-3bf7856aab84")
    create(:content_item, title: "Page Bar", content_id: "5b4b844c-cf63-4a27-814c-a03b2c4b16ae")

    csv = <<-doc
content_id
5d18871a-6d63-49aa-9c60-3bf7856aab84
5b4b844c-cf63-4a27-814c-a03b2c4b16ae
    doc

    stub_request(:get, "https://example.org/spreadsheet.csv").
      to_return(status: 200, body: csv)

    fill_in :new_taxonomy_project_name, with: "Project Foo"
    fill_in :new_taxonomy_project_csv_url, with: "https://example.org/spreadsheet.csv"
    click_button "Save"
  end

  def then_i_should_see_the_project
    expect(page).to have_content "Project Foo"
    expect(page).to have_content "Page Foo"
    expect(page).to have_content "Page Bar"
  end
end
