RSpec.feature "Reporting on audit progress" do
  # Organisations:
  let!(:hmrc) { FactoryGirl.create(:content_item, title: "HMRC", document_type: "organisation") }

  # Policies:
  let!(:flying) { FactoryGirl.create(:content_item, title: "Flying abroad", document_type: "policy") }
  let!(:insurance) { FactoryGirl.create(:content_item, title: "Travel insurance", document_type: "policy") }

  before do
    FactoryGirl.create(:audit, content_item: flying)
  end

  scenario "Displaying the number of items included in the audit" do
    visit audits_report_path
    expect(page).to have_content("3 Content items")

    select "Organisation", from: "document_type"
    click_on "Filter"
    expect(page).to have_content("1 Content items")

    select "Policy", from: "document_type"
    click_on "Filter"
    expect(page).to have_content("2 Content items")
  end

  scenario "Displaying the number of items audited/not audited" do
    visit audits_report_path

    expect(page).to have_content("Items audited 1 33%")
    expect(page).to have_content("Items still to audit 2 67%")

    bar = page.find("#progress .bar .inner")
    expect(bar[:style]).to eq("width: 33.33333%")
  end
end
