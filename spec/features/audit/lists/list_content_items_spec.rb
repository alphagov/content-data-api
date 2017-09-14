RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  scenario "User does not see CPM feedback survey link in banner" do
    visit audits_path

    expect(page).to have_no_link("these quick questions")
  end

  scenario "List Content Items to Audit" do
    create(:content_item, title: "item1", six_months_page_views: 10_000, content_id: "content-id")
    create(:content_item, title: "item2")

    visit audits_path

    expect(page).to have_content("item1")
    expect(page).to have_content("10,000")
    expect(page).to have_link("item1", href: "/content_items/content-id/audit")

    expect(page).to have_content("item2")
  end

  scenario "Displays the number of content items" do
    create_list :content_item, 2

    visit audits_path

    expect(page).to have_text("2 items")
  end

  scenario "List content items of auditable formats" do
    create(:content_item, document_type: "guide")
    create(:content_item, document_type: "other-format")

    visit audits_path

    expect(page).to have_css("main tbody tr", count: 1)
  end

  describe "pagination" do
    let!(:content_items) {
      create_list(:content_item, 30)
        .sort_by(&:base_path)
        .reverse
    }

    scenario "Showing 25 items on the first page" do
      visit audits_path

      content_items[0..24].each do |content_item|
        expect(page).to have_content(content_item.title)
      end

      content_items[25..29].each do |content_item|
        expect(page).to have_no_content(content_item.title)
      end
    end

    scenario "Showing the second page of items" do
      visit audits_path

      click_link "Next →"

      content_items[0..24].each do |content_item|
        expect(page).to have_no_content(content_item.title)
      end

      content_items[25..29].each do |content_item|
        expect(page).to have_content(content_item.title)
      end
    end

    scenario "Clicking 'Next' on content items" do
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
end
