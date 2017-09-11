RSpec.feature "Notifying of no content to audit", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  context "there is no content for my organisation to audit" do
    before(:each) do
      @current_user.organisation_slug = SecureRandom.base64
      @current_user.save

      visit audits_path
    end

    context "viewing content assigned to me" do
      before(:each) do
        select "Me", from: :allocated_to
        click_on "Apply filters"
      end

      scenario "not audited content should show a banner" do
        choose "Not audited"
        click_on "Apply filters"
        expect(page).to have_content("You have no content to audit.")
        expect(page).to have_css(".alert")
        expect(page).to have_css(".alert a")
      end

      scenario "audited content should not show a banner" do
        choose "Audited"
        click_on "Apply filters"
        expect(page).to have_no_content("You have no content to audit.")
        expect(page).to have_no_css(".alert")
      end

      scenario "all content should not show a banner" do
        choose "All"
        click_on "Apply filters"
        expect(page).to have_no_content("You have no content to audit.")
        expect(page).to have_no_css(".alert")
      end
    end

    context "viewing content assigned to someone else" do
      let!(:someone_else) do
        create(:user, organisation_slug: @current_user.organisation_slug)
      end

      before(:each) do
        visit audits_path
        select someone_else.name, from: :allocated_to
        click_on "Apply filters"
      end

      scenario "not audited content should show a banner" do
        choose "Not audited"
        click_on "Apply filters"
        expect(page).to have_content("#{someone_else.name} has no content to audit.")
        expect(page).to have_css(".alert")
        expect(page).to have_css(".alert a")
      end
    end

    context "viewing content assigned to no one" do
      before(:each) do
        select "No one", from: :allocated_to
        click_on "Apply filters"
      end

      scenario "not audited content should show a banner" do
        choose "Not audited"
        click_on "Apply filters"
        expect(page).to have_no_css(".alert")
      end
    end

    context "viewing content assigned to anyone" do
      before(:each) do
        select "Anyone", from: :allocated_to
        click_on "Apply filters"
      end

      scenario "not audited content should show a banner" do
        choose "Not audited"
        click_on "Apply filters"
        expect(page).to have_no_css(".alert")
      end
    end
  end
end
