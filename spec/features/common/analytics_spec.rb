RSpec.feature "Analytics", type: :feature do
  let!(:my_organisation) do
    create(
      :organisation,
      base_path: "google-tag-manager",
    )
  end

  let!(:me) do
    create(
      :user,
      organisation: my_organisation,
    )
  end

  context "Tracking select elements" do
    scenario "all select elements have a data-tracking-id attribute" do
      paths_to_check = [
        audits_allocations_path,
        audits_path,
        audits_report_path,
      ]

      paths_to_check.each do |path|
        visit path

        selects = all("select")
        expect(selects).not_to be_empty

        selects.each do |select|
          expect(select['data-tracking-id'].blank?).to be(false)
        end
      end
    end
  end

  context "Tracking information from the server" do
    scenario "the user's organisation is in the Google Tag Manager data layer", js: true do
      visit audits_path

      data_layer = page.evaluate_script("dataLayer")
      expect(data_layer).to include("organisation" => "google-tag-manager")
    end
  end
end
