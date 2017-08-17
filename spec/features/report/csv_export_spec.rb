RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  context "Two content items are in the database" do
    let!(:hmrc) {
      create(
        :content_item,
        title: "HMRC",
        document_type: "organisation"
      )
    }

    before do
      example1 = create(
        :content_item,
        title: "Example 1",
        base_path: "/example1",
      )

      create(
        :link,
        source_content_id: example1.content_id,
        target_content_id: hmrc.content_id,
        link_type: "primary_publishing_organisation",
      )

      create(
        :content_item,
        title: "Example 2",
        base_path: "/example2",
      )

      tax_audit = create(:audit, content_item: example1)
      create(
        :response,
        question: create(:boolean_question),
        audit: tax_audit,
        value: "no"
      )
    end

    scenario "Exporting a csv file as an attachment" do
      visit audits_report_path
      click_link "Export filtered audit to CSV"

      expect(content_type).to eq("text/csv")
      expect(content_disposition).to start_with("attachment")
      expect(content_disposition).to include(
        'filename="Transformation_audit_report_CSV_download.csv"',
      )

      expect(page).to have_content("Title,URL")
      expect(page).to have_content("Example 1,https://gov.uk/example1")
    end

    scenario "Applying the filters to the export" do
      visit audits_report_path

      select "HMRC", from: "organisations"
      click_on "Filter"

      click_link "Export filtered audit to CSV"
      expect(page).to have_content("Example 1,https://gov.uk/example1")
      expect(page).to have_no_content("Example 2,https://gov.uk/example2")
    end

    scenario "Discard audit status filter when clicking from content view to report, and then exporting CSV" do
      visit audits_path
      select "Audited", from: "audit_status"

      click_on "Filter"
      expect(page).to have_content("Example 1")
      expect(page).to have_no_content("Example 2")

      click_link "Report"

      click_link "Export filtered audit to CSV"
      expect(content_disposition).to include(
        'filename="Transformation_audit_report_CSV_download.csv"',
      )
      expect(page).to have_content("Example 1")
      expect(page).to have_content("Example 2")
    end
  end

  context "Multiple pages of content items are in the database" do
    let!(:content_items) { create_list(:content_item, 50) }

    scenario "Exporting an unfiltered audit to CSV with all the content items" do
      visit audits_report_path
      click_link "Export filtered audit to CSV"

      csv = CSV.parse(page.body, headers: true)

      number_of_metadata_rows = 1
      expect(csv.count).to eq(content_items.count + number_of_metadata_rows)
    end
  end
end
