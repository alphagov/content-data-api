RSpec.feature "Notifying of no content to audit", type: :feature do
  let!(:narnia) do
    create(
      :organisation,
      title: "Narnia",
    )
  end

  let!(:me) do
    create(
      :user,
      name: "C. S. Lewis",
      organisation: narnia,
    )
  end

  context "there is no content for my organisation to audit" do
    before(:each) do
      visit audits_my_content_path
    end

    context "viewing content assigned to me" do
      scenario "not audited content should show a banner" do
        choose "Not audited"
        click_on "Apply filters"
        expect(page).to have_content("You have no content to audit.")
        expect(page).to have_css(".alert")
        expect(page).to have_css(".alert a")
      end

      scenario "audited content should show a banner" do
        choose "Audited"
        click_on "Apply filters"
        expect(page).to have_content("You have no content to audit.")
        expect(page).to have_css(".alert")
      end

      scenario "all content, assigned to 'Me', should show a banner" do
        choose "All"
        click_on "Apply filters"
        expect(page).to have_content("You have no content to audit.")
        expect(page).to have_css(".alert")
      end
    end
  end
end
