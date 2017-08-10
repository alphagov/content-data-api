RSpec.feature "Header of Content Items List", type: :feature do
  before do
    FactoryGirl.create(:user)
  end

  context "When no filter is present" do
    scenario "Renders GOV.UK" do
      visit "/content/items"

      expect(page).to have_selector("h1", text: "GOV.UK")
    end
  end

  context "When a filter is present" do
    let!(:hmrc) { create(:content_item, content_id: 1, title: "HMRC") }
    let!(:taxon1) { create(:content_item, content_id: 2, title: "TAXON") }

    scenario "Renders GOV.UK" do
      visit "/content/items?organisations=1&taxons=2"

      expect(page).to have_selector('h1', text: "HMRC + TAXON")
    end
  end
end
