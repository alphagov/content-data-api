require "rails_helper"

RSpec.feature "Generating terms", type: :feature do
  it "allows users to generate terms" do
    given_theres_a_project_with_todos

    when_i_visit_the_taxonomy_project_page
    and_i_click_to_start_with_a_project
    then_i_should_see_a_page
    when_i_submit_a_term
    then_the_term_is_saved
    and_i_see_the_next_page

    when_i_go_to_the_project_page
    then_i_see_the_generated_terms
  end

  def given_theres_a_project_with_todos
    @project = create(:taxonomy_project, name: 'A Fancy Group')

    @content_item = create(:content_item, title: 'A Fancy Content Item')
    @another_content_item = create(:content_item, title: 'Another Content Item')
    @todo = create(:taxonomy_todo, content_item: @content_item, taxonomy_project: @project)
    create(:taxonomy_todo, content_item: @another_content_item, taxonomy_project: @project)
  end

  def when_i_visit_the_taxonomy_project_page
    visit taxonomy_projects_path
  end

  def and_i_click_to_start_with_a_project
    click_on 'Start tagging'
  end

  def then_i_should_see_a_page
    expect(page.body).to match "A Fancy Content Item"
  end

  def when_i_submit_a_term
    fill_in :taxonomy_todo_form_new_terms, with: "The First, The Second, The Third"
    click_on "Save"
    @todo.reload
  end

  def then_the_term_is_saved
    expect(@todo).to be_completed
    expect(@content_item.terms.where(taxonomy_project: @project).count).to eql(3)
  end

  def and_i_see_the_next_page
    expect(page.body).not_to match "A Fancy Content Item"
  end

  def when_i_go_to_the_project_page
    visit taxonomy_project_path(@project)
  end

  def then_i_see_the_generated_terms
    expect(page).to have_content 'The First'
    expect(page).to have_content 'The Second'
    expect(page).to have_content 'The Third'
  end
end
