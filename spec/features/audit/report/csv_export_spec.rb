RSpec.feature "Exporting a CSV from the report page" do
  let!(:me) do
    create(
      :user,
    )
  end

  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  scenario "Exporting a csv file as an attachment" do
    given_i_am_exporting_an_audit_report
    then_i_download_a_csv_file
  end

  scenario "Applying the filters to the export" do
    given_i_have_applied_filters_and_exported_audit
    then_i_download_a_csv_file_for_the_filtered_audits
  end

  scenario "Multiple pages of content items are in the database" do
    given_i_have_multiple_pages_of_content_items_and_do_not_filter_them
    then_i_download_a_csv_file_for_all_content_items
  end

  def given_i_am_exporting_an_audit_report
    user = create(:user)
    hmrc = create(
      :content_item,
      title: "HMRC",
      document_type: "organisation"
    )
    example1 = create(:content_item,
                      title: "Example 1",
                      base_path: "/example1",
                      allocated_to: me)
    create(:link,
           source_content_id: example1.content_id,
           target_content_id: hmrc.content_id,
           link_type: "primary_publishing_organisation")
    example2 = create(:content_item,
           title: "Example 2",
           base_path: "/example2")
    create(:audit, content_item: example1)
    @audit_report_item = ContentAuditTool.new.audit_report_item
    @audit_report_item.load(content_id: example2.content_id)
    @audit_report_item.export_to_csv.click
  end

  def then_i_download_a_csv_file
    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include(
      'filename="Transformation_audit_report_CSV_download.csv"',
    )
    expect(@audit_report_item).to have_content("Title,URL")
    expect(@audit_report_item).to have_content("Example 1,https://gov.uk/example1")
    expect(@audit_report_item).to have_content("Example 1,https://gov.uk/example1")
  end

  def given_i_have_applied_filters_and_exported_audit
    user = create(:user)
    hmrc = create(
      :content_item,
      title: "HMRC",
      document_type: "organisation"
    )
    example1 = create(:content_item,
                      title: "Example 1",
                      base_path: "/example1",
                      allocated_to: me)
    create(:link,
           source_content_id: example1.content_id,
           target_content_id: hmrc.content_id,
           link_type: "primary_publishing_organisation")
    example2 = create(:content_item,
           title: "Example 2",
           base_path: "/example2")
    create(:audit, content_item: example1)
    @audit_report_item = ContentAuditTool.new.audit_report_item
    @audit_report_item.load(content_id: example2.content_id)
    @audit_report_item.allocated_to.select 'Anyone'
    @audit_report_item.organisations.select 'HMRC'
    @audit_report_item.apply_filters.click
    @audit_report_item.export_to_csv.click
  end

  def then_i_download_a_csv_file_for_the_filtered_audits
    expect(@audit_report_item).to have_content("Title,URL")
    expect(@audit_report_item).to have_content("Example 1,https://gov.uk/example1")
    expect(@audit_report_item).to have_no_content("Example 2,https://gov.uk/example2")
  end

  def given_i_have_multiple_pages_of_content_items_and_do_not_filter_them
    user = create(:user)
    create_list(:content_item, 110)
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
  end

  def then_i_download_a_csv_file_for_all_content_items
    click_link "Export filtered audit to CSV"
    csv = CSV.parse(page.body, headers: true)
    number_of_metadata_rows = 1
    expect(csv.count).to eq(Content::Item.count + number_of_metadata_rows)
  end
end
