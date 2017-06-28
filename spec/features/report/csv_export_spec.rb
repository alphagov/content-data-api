RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  let!(:hmrc) {
    FactoryGirl.create(
      :content_item,
      title: "HMRC",
      document_type: "organisation"
    )
  }

  before do
    example1 = FactoryGirl.create(
      :content_item,
      title: "Example 1",
      base_path: "/example1",
    )

    FactoryGirl.create(
      :link,
      source_content_id: example1.content_id,
      target_content_id: hmrc.content_id,
      link_type: "primary_publishing_organisation",
    )

    FactoryGirl.create(
      :content_item,
      title: "Example 2",
      base_path: "/example2",
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

    select "HMRC (1)", from: "organisations"
    click_on "Filter"

    click_link "Export filtered audit to CSV"
    expect(page).to have_no_content("Example,https://gov.uk/example")
  end
end
