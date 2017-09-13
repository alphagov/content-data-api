RSpec.feature "Sort content items to audit", type: :feature do
  scenario "Default sorting by popularity" do
    create(:content_item, six_months_page_views: 0, title: "item1", allocated_to: @current_user)
    create(:content_item, six_months_page_views: 1234, title: "item2", allocated_to: @current_user)

    visit audits_path

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match("item2")
    expect(rows[1].text).to match("item1")
  end

  scenario "Sort list by title A-Z" do
    create(:content_item, title: "BBBB")
    create(:content_item, title: "AAA")
    create(:content_item, title: "CCC")

    visit audits_path
    select "Anyone", from: "allocated_to"

    select "Title A-Z", from: "sort_by"
    click_on "Apply filters"

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match("AAA")
    expect(rows[1].text).to match("BBB")
    expect(rows[2].text).to match("CCC")
  end

  scenario "Sort list by title Z-A" do
    create(:content_item, title: "BBBB")
    create(:content_item, title: "AAA")
    create(:content_item, title: "CCC")

    visit audits_path
    select "Anyone", from: "allocated_to"

    select "Title Z-A", from: "sort_by"
    click_on "Apply filters"

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match("CCC")
    expect(rows[1].text).to match("BBB")
    expect(rows[2].text).to match("AAA")
  end
end
