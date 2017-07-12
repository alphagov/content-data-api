require "rails_helper"

RSpec.feature "Generating terms", type: :feature do
  it "allows users to generate terms" do
    given_theres_a_project_with_todos

    when_i_visit_the_taxonomy_project_page
    and_i_click_to_start_with_a_project
    then_i_should_see_a_page
    when_i_submit_terms
    then_the_terms_are_saved
    and_i_see_the_next_page

    when_i_go_to_the_project_page
    then_i_see_the_generated_terms

    when_i_go_to_the_complete_todo_page
    then_i_see_the_previously_generated_terms

    when_i_submit_revised_terms
    then_the_revised_terms_are_saved
  end

  it "allows users to say that they don't know" do
    given_theres_a_project_with_todos

    when_i_visit_the_taxonomy_project_page
    and_i_click_to_start_with_a_project
    then_i_should_see_a_page

    when_i_click_i_dont_know
    then_the_todo_is_marked_as_dont_know
    and_i_see_the_next_page
  end

  it "allows users to say that the page isn't relevant" do
    given_theres_a_project_with_todos

    when_i_visit_the_taxonomy_project_page
    and_i_click_to_start_with_a_project
    then_i_should_see_a_page

    when_i_click_this_is_not_relevant
    then_the_todo_is_marked_as_irrelevant
    and_i_see_the_next_page
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

  def when_i_submit_terms
    fill_in :taxonomy_todo_form_terms, with: "The First, The Second, The Third"
    click_on "Save"
    @todo.reload
  end

  def when_i_submit_revised_terms
    fill_in :taxonomy_todo_form_terms, with: "The First, The Second, The Forth"
    click_on "Save"
    @todo.reload
  end

  def when_i_click_i_dont_know
    click_button "I don't know"
    @todo.reload
  end

  def when_i_click_this_is_not_relevant
    click_button "This page is not relevant / relevant to different theme"
    @todo.reload
  end

  def then_the_todo_is_marked_as_dont_know
    expect(@todo).to be_completed
    expect(@todo.status).to eql(TaxonomyTodo::STATE_DONT_KNOW)
  end

  def then_the_terms_are_saved
    expect(@todo).to be_completed
    expect(@todo.terms.pluck(:name))
      .to contain_exactly('The First', 'The Second', 'The Third')
  end

  def then_the_revised_terms_are_saved
    expect(@todo).to be_completed
    expect(@todo.terms.pluck(:name))
      .to contain_exactly('The First', 'The Second', 'The Forth')
  end

  def and_i_see_the_next_page
    expect(page.body).not_to match "A Fancy Content Item"
  end

  def then_the_todo_is_marked_as_irrelevant
    expect(@todo).to be_completed
    expect(@todo.status).to eql(TaxonomyTodo::STATE_NOT_RELEVANT)
  end

  def when_i_go_to_the_project_page
    visit taxonomy_project_path(@project)
  end

  def when_i_go_to_the_complete_todo_page
    visit taxonomy_todo_path(@todo)
  end

  def then_i_see_the_generated_terms
    expect(page).to have_content 'The First'
    expect(page).to have_content 'The Second'
    expect(page).to have_content 'The Third'
  end

  def then_i_see_the_previously_generated_terms
    expect(page).to have_field('Terms', with: 'The First,The Second,The Third')
  end
end
