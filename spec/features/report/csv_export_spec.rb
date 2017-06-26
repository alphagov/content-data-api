RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  before do
    example = FactoryGirl.create(
      :content_item,
      title: "Example",
      base_path: "/example",
    )

    FactoryGirl.create(:audit, content_item: example)
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
    expect(page).to have_content("Example,https://gov.uk/example")
  end

  scenario "Applying the filters to the export" do
    visit audits_report_path

    select "Non Audited", from: "audit_status"
    click_on "Filter"

    click_link "Export filtered audit to CSV"
    expect(page).to have_no_content("Example,https://gov.uk/example")
  end
end
