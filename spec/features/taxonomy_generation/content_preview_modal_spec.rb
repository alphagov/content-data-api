require "rails_helper"

RSpec.feature "Content Preview Modal", type: :feature, js: true do
  let!(:me) do
    create(
      :user,
    )
  end

  before :each do
    #ignore the fact the iframe points to an invalid path
    Capybara.raise_server_errors = false
  end

  it "pops up a modal when previewing content" do
    given_theres_a_project_with_a_todo
    when_i_visit_the_taxonomy_project_page
    and_i_click_to_start_with_a_project
    and_i_click_on_the_content_link
    then_a_modal_with_the_content_pops_up
  end

  def given_theres_a_project_with_a_todo
    @project = create(:taxonomy_project, name: 'A Fancy Group')
    @content_item = create(:content_item, title: 'A Fancy Content Item', base_path: "/path/to/a/page.html")
    @todo = create(:taxonomy_todo, content_item: @content_item, taxonomy_project: @project)
  end

  def when_i_visit_the_taxonomy_project_page
    visit taxonomy_projects_path
  end

  def and_i_click_to_start_with_a_project
    click_on 'Start tagging'
  end

  def and_i_click_on_the_content_link
    click_on 'A Fancy Content Item'
  end

  def then_a_modal_with_the_content_pops_up
    within('.modal-content') do
      expect(page).to have_css('iframe[src="/iframe-proxy/path/to/a/page.html"]')
    end
  end
end
