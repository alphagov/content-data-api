RSpec.feature "Navigation" do
  let!(:first) { FactoryGirl.create(:content_item, title: "First", six_months_page_views: 3) }
  let!(:second) { FactoryGirl.create(:content_item, title: "Second", six_months_page_views: 2) }
  let!(:third) { FactoryGirl.create(:content_item, title: "Third", six_months_page_views: 1) }

  scenario "navigating between audits and the index page" do
    visit audits_path(some_filter: "value")
    click_link "First"

    expected = content_item_audit_path(first, some_filter: "value")
    expect(current_url).to end_with(expected)

    click_link "Next"

    expected = content_item_audit_path(second, some_filter: "value")
    expect(current_url).to end_with(expected)

    click_link "Next"

    expected = content_item_audit_path(third, some_filter: "value")
    expect(current_url).to end_with(expected)

    expect(page).to have_no_link("Next")

    click_link "< All items"

    expected = audits_path(some_filter: "value")
    expect(current_url).to end_with(expected)
  end

  scenario "returning to the first page of the index" do
    visit content_item_audit_path(first, some_filter: "value", page: "123")
    click_link "< All items"

    expected = audits_path(some_filter: "value")
    expect(current_url).to end_with(expected)
  end

  scenario "continuing to next item on save" do
    visit content_item_audit_path(first, some_filter: "value")

    within("#question-1") { choose "No" }
    within("#question-2") { choose "No" }
    within("#question-3") { choose "No" }
    within("#question-4") { choose "No" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "No" }
    within("#question-7") { choose "No" }
    within("#question-8") { choose "No" }

    click_on "Save"

    expected = content_item_audit_path(second, some_filter: "value")
    expect(current_url).to end_with(expected)

    expect(page).to have_content("Success: Saved successfully and continued to next item.")
  end

  scenario "not continuing to next item if fails to save" do
    visit content_item_audit_path(first, some_filter: "value")

    click_on "Save"

    expected = content_item_audit_path(first, some_filter: "value")
    expect(current_url).to end_with(expected)

    expect(page).to have_content("Warning: Mandatory field missing")

    click_on "Next"

    expected = content_item_audit_path(second, some_filter: "value")
    expect(current_url).to end_with(expected)
  end

  context "when on the second page of content items" do
    before do
      FactoryGirl.create_list(:content_item, 25, six_months_page_views: 2)

      FactoryGirl.create(:content_item, title: "Penultimate item", six_months_page_views: 1)
      FactoryGirl.create(:content_item, title: "Last item", six_months_page_views: 0)

      visit audits_path(page: 2)
    end

    scenario "continuing to the next item from the audit page" do
      click_link "Penultimate item"
      click_on "Next"

      expect(page).to have_content("Last item")
      expect(page).to have_no_link "Next"
    end
  end
end
