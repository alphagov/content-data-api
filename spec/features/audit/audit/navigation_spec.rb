RSpec.feature "Navigation", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  context "with three items with different numbers of page views allocated to me" do
    let!(:peter_rabbit) do
      create(
        :content_item,
        title: "Peter Rabbit",
        six_months_page_views: 10,
        allocated_to: me,
      )
    end

    let!(:jemima_puddle_duck) do
      create(
        :content_item,
        title: "Jemima Puddle-Duck",
        six_months_page_views: 9,
      )
    end

    let!(:benjamin_bunny) do
      create(
        :content_item,
        title: "Benjamin Bunny",
        six_months_page_views: 8,
      )
    end

    let!(:squirrel_nutkin) do
      create(
        :content_item,
        title: "Squirrel Nutkin",
        six_months_page_views: 7,
        allocated_to: me,
      )
    end

    let!(:timmy_tiptoes) do
      create(
        :content_item,
        title: "Timmy Tiptoes",
        six_months_page_views: 6,
        allocated_to: me,
      )
    end

    let!(:miss_moppet) do
      create(
        :content_item,
        title: "Miss Moppet",
        six_months_page_views: 5,
        allocated_to: me,
      )
    end

    let(:filter_params) do
      {
        allocated_to: me.uid,
        audit_status: 'non_audited',
        primary: true,
      }
    end

    scenario "navigating between audits and the index page" do
      visit audits_my_content_path
      click_link "Peter Rabbit"

      expected = content_item_audit_path(peter_rabbit, **filter_params)
      expect(current_url).to end_with(expected)

      click_link "< All items"

      expected = audits_path(**filter_params)
      expect(current_url).to end_with(expected)
    end

    scenario "returning to the first page of the index" do
      visit audits_my_content_path
      click_link "Peter Rabbit"
      click_link "< All items"

      expected = audits_path(**filter_params)
      expect(current_url).to end_with(expected)
    end

    scenario "continuing to next item on save" do
      visit audits_my_content_path
      click_link "Peter Rabbit"
      perform_audit

      expected = content_item_audit_path(squirrel_nutkin, **filter_params)
      expect(current_url).to end_with(expected)

      expect(page).to have_content("Audit saved — 3 items remaining.")
    end

    scenario "not continuing to next item if fails to save" do
      visit audits_my_content_path
      click_link "Peter Rabbit"
      click_on "Save and continue"

      expected = content_item_audit_path(peter_rabbit, **filter_params)
      expect(current_url).to end_with(expected)

      expect(page).to have_content("Please answer all the questions.")
    end

    scenario "continuing to the next unaudited item on save" do
      visit audits_my_content_path
      click_link "Squirrel Nutkin"
      perform_audit

      visit audits_path
      select "Anyone", from: "allocated_to"

      choose "Not audited"
      click_on "Apply filters"

      expect(page).to have_content("Peter Rabbit")
      expect(page).to have_content("Jemima Puddle-Duck")
      expect(page).to have_content("Benjamin Bunny")
      expect(page).to_not have_content("Squirrel Nutkin")
      expect(page).to have_content("Timmy Tiptoes")
      expect(page).to have_content("Miss Moppet")

      click_link "Peter Rabbit"
      perform_audit

      expected = content_item_audit_path(jemima_puddle_duck,
                                         allocated_to: 'anyone',
                                         audit_status: 'non_audited',
                                         primary: true)
      expect(current_url).to end_with(expected)

      expect(page).to have_content("Audit saved — 4 items remaining.")
    end
  end

  def answer_question(question, answer)
    find('p', text: question)
      .first(:xpath, '..//..')
      .choose(answer)
  end

  def perform_audit
    answer_question "Title", "No"
    answer_question "Summary", "No"
    answer_question "Page detail", "No"
    answer_question "Attachments", "No"
    answer_question "Content type", "No"
    answer_question "Is the content out of date?", "No"
    answer_question "Should the content be removed?", "No"
    answer_question "Is this content very similar to other pages?", "No"

    click_on "Save and continue"
  end
end
