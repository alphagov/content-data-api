RSpec.feature "Reporting on audit progress" do
  let!(:content_item) { create(:content_item, document_type: "transaction") }
  let!(:flying) { create(:content_item, document_type: "transaction") }
  let!(:insurance) { create(:content_item, document_type: "transaction") }

  before do
    create(:passing_audit, content_item: flying)
    create(:failing_audit, content_item: insurance)
  end

  def width(id)
    page.find("#{id} .progress .progress-bar")[:style]
  end

  scenario "Displaying the number of items included in the audit" do
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("3 Content items")

    select "Guide", from: "document_type"
    click_on "Apply filters"
    expect(page).to have_content("0 Content items")

    select "Transaction", from: "document_type"
    click_on "Apply filters"
    expect(page).to have_content("3 Content items")
  end

  scenario "Displaying the number of items audited/not audited" do
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("Items audited 2 67%")
    expect(page).to have_content("Items still to audit 1 33%")
    expect(width("#progress")).to eq("width: 66.66667%;")
  end

  scenario "Displaying the number of items needing improvement/not needing improvement" do
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("Items that need improvement 1 50%")
    expect(page).to have_content("Items that don't need improvement 1 50%")
    expect(width("#items-needing-improvement")).to eq("width: 50%;")
  end

  scenario "Audit status filter is not present" do
    visit audits_report_path

    expect(page).to have_no_content("Audit status")
  end
end
