RSpec.feature "Audit metadata", type: :feature do
  let!(:content_item) do
    FactoryGirl.create(
      :content_item,
      public_updated_at: nil,
      document_type: "document_collection",
    )
  end

  around do |example|
    Timecop.freeze(2017, 1, 1) { example.run }
  end

  scenario "showing minimal metadata next to the audit quesionnaire" do
    visit content_item_audit_path(content_item)

    within("#metadata") do
      expect(page).to have_selector("#audited", text: "Not audited yet")
      expect(page).to have_selector("#organisations", text: "None")
      expect(page).to have_selector("#last-updated", text: "Never")
      expect(page).to have_selector("#content-type", text: "Document Collection")
      expect(page).to have_selector("#guidance", text: "No")
      expect(page).to have_selector("#topics", text: "None")
      expect(page).to have_selector("#policy-areas", text: "None")
      expect(page).to have_selector("#withdrawn", text: "No")
      expect(page).to have_selector("#pageviews", text: "None in the last month")
      expect(page).to have_selector("#pageviews", text: "None in the last six months")
    end
  end

  def create_linked_content(link_type, title)
    target = FactoryGirl.create(:content_item, title: title)

    FactoryGirl.create(
      :link,
      link_type: link_type,
      source_content_id: content_item.content_id,
      target_content_id: target.content_id,
    )
  end

  scenario "showing maximal metadata next to the audit questionnaire" do
    content_item.update!(
      public_updated_at: "2017-01-03",
      one_month_page_views: 1234,
      six_months_page_views: 12345,
      document_type: "guidance",
    )

    FactoryGirl.create(:audit, content_item: content_item)

    create_linked_content("organisations", "Home office")
    create_linked_content("topics", "Immigration")
    create_linked_content("topics", "Borders")
    create_linked_content("policy-areas", "Borders and Immigration")

    visit content_item_audit_path(content_item)

    within("#metadata") do
      audited_text = "Audited 01/01/17 (less than a minute ago) by Test User Government Digital Service"
      expect(page).to have_selector("#audited", text: audited_text)
      expect(page).to have_selector("#organisations", text: "Organisations Home office")
      expect(page).to have_selector("#last-updated", text: "03/01/17 (2 days ago)")
      expect(page).to have_selector("#content-type", text: "Guidance")
      expect(page).to have_selector("#guidance", text: "Yes")
      expect(page).to have_selector("#topics", text: "Borders, Immigration")
      expect(page).to have_selector("#policy-areas", text: "Borders and Immigration")
#      expect(page).to have_selector("#withdrawn", text: "No")
      expect(page).to have_selector("#pageviews", text: "1,234 in the last month")
      expect(page).to have_selector("#pageviews", text: "12,345 in the last six months")
    end
  end
end
