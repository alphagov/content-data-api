RSpec.feature "Navigation" do
  context "with three items with different numbers of page views" do
    let!(:first) { create(:content_item, title: "First", six_months_page_views: 10) }
    let!(:second) { create(:content_item, title: "Second", six_months_page_views: 9) }
    let!(:third) { create(:content_item, title: "Third", six_months_page_views: 8) }

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

      perform_audit

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

    scenario "continuing to the next unadited item on save" do
      visit content_item_audit_path(second)
      perform_audit

      visit audits_path
      select "Non Audited", from: "audit_status"
      click_on "Filter"

      expect(page).to have_content(first.title)
      expect(page).to have_no_content(second.title)
      expect(page).to have_content(third.title)

      click_link first.title
      perform_audit
      expect(current_url).to include(content_item_audit_path(third))
    end
  end

  context "when there are multiple pages of content items" do
    let!(:content_items) {
      create_list(:content_item, 30)
        .sort_by(&:base_path)
        .reverse
    }

    scenario "Clicking 'Next' to navigate between individual content items" do
      visit audits_path

      click_link content_items[0].title

      (content_items.count - 1).times do |index|
        expect(page).to have_content(content_items[index].title)
        click_link "Next"
      end

      expect(page).to have_content(content_items.last.title)
      expect(page).to have_no_content "Next"
    end
  end

  def perform_audit
    within("#question-1") { choose "No" }
    within("#question-2") { choose "No" }
    within("#question-3") { choose "No" }
    within("#question-4") { choose "No" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "No" }
    within("#question-7") { choose "No" }
    within("#question-8") { choose "No" }

    click_on "Save"
  end
end
