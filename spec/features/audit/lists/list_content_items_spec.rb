RSpec.feature "List Content Items to Audit", type: :feature do
  scenario "User does not see CPM feedback survey link in banner" do
    visit audits_path

    expect(page).to have_no_link("these quick questions")
  end

  scenario "List Content Items to Audit" do
    content_item1 = create(:content_item, six_months_page_views: 10_000, allocated_to: @current_user)
    content_item2 = create(:content_item, allocated_to: @current_user)

    visit audits_path

    expect(page).to have_content(content_item1.title)
    expect(page).to have_content("10,000")
    expect(page).to have_link(content_item1.title, href: "/content_items/#{content_item1.content_id}/audit")

    expect(page).to have_content(content_item2.title)
  end

  scenario "Displays the number of content items" do
    create_list(:content_item, 2, allocated_to: @current_user)

    visit audits_path

    expect(page).to have_text("2 items")
  end

  scenario "List content items of auditable formats" do
    create(:content_item, document_type: "guide", allocated_to: @current_user)
    create(:content_item, document_type: "other-format", allocated_to: @current_user)

    visit audits_path

    expect(page).to have_css("main tbody tr", count: 1)
  end

  describe "pagination" do
    let!(:content_items) {
      create_list(:content_item, 30, allocated_to: @current_user)
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
