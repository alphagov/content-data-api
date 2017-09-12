RSpec.feature "Analytics", type: :feature do
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
end
