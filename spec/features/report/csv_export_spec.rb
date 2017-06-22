RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  before do
    example = FactoryGirl.create(:content_item, title: "Example")
    FactoryGirl.create(:audit, content_item: example)
  end

  scenario "Exporting a csv file as an attachment" do
    visit audits_report_path
    click_link "Export filtered audit to CSV"

    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include('filename="report.csv"')

    expect(page).to have_content("Title,Audited by")
    expect(page).to have_content("Example,Test User")
  end

  scenario "Applying the filters to the export" do
    visit audits_report_path

    select "Non Audited", from: "audit_status"
    click_on "Filter"

    click_link "Export filtered audit to CSV"
    expect(page).to have_no_content("Example,Test User")
  end
end
