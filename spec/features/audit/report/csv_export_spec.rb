RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  scenario "Exporting a csv file as an attachment" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_audits
    when_i_export_an_audit_report
    then_i_receive_the_report_in_csv_format
  end

  scenario "Applying the filters to the export" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_audits
    and_they_are_filtered
    when_i_export_the_reports
    then_i_receive_an_audit_progress_report_for_filtered_audits_in_csv_format
  end

  scenario "Multiple pages including_details_of_audit_progress_ of content items are in the database" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_audits
    and_there_are_multiple_pages_of_unfiltered_content_items
    when_i_export_all_the_reports
    then_i_receive_an_audit_progress_report_for_all_audits_in_csv_format
  end

  scenario "Discard audit status filter when clicking from content view to report, and then exporting CSV" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_audits
    when_i_apply_filters
    then_i_see_the_two_content_items_which_match_the_filters
    when_i_navigate_to_audits_report_page
    then_i_see_one_content_item_which_matches_default_filters
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
                      allocated_to: user)
    create(:link,
           source_content_id: example1.content_id,
           target_content_id: hmrc.content_id,
           link_type: "primary_publishing_organisation")
    create(:content_item,
           title: "Example 2",
           base_path: "/example2",
           allocated_to: nil)
    create(:content_item,
           title: "Example 3",
           base_path: "/example3",
           allocated_to: nil)
    create(:audit, content_item: example1)
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load(content_id: Content::Item.last.content_id)
    @audit_report.export_to_csv.click
  end

  def given_i_am_an_auditor_belonging_to_an_organisation_with_audits
    user = create(:user)
    hmrc = create(
      :content_item,
      title: "HMRC",
      document_type: "organisation",
      allocated_to: user
    )
    example1 = create(:content_item,
                      title: "Example 1",
                      base_path: "/example1",
                      allocated_to: user)
    create(:link,
           source_content_id: example1.content_id,
           target_content_id: hmrc.content_id,
           link_type: "primary_publishing_organisation")
    create(:content_item,
           title: "Example 2",
           base_path: "/example2",
           allocated_to: nil)
    create(:content_item,
           title: "Example 3",
           base_path: "/example3",
           allocated_to: nil)
    create(:audit, content_item: example1)
  end

  def then_i_receive_an_audit_progress_report_for_filtered_audits_in_csv_format
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Example 1,https://gov.uk/example1")
    expect(@audit_report).to have_no_content("Example 2,https://gov.uk/example2")
  end

  def then_i_see_the_two_content_items_which_match_the_filters
    expect(@audit_content_page).to have_no_content("Example 1")
    expect(@audit_content_page).to have_content("Example 2")
    expect(@audit_content_page).to have_content("Example 3")
  end

  def when_i_navigate_to_audits_report_page
    @audit_content_page.audits_progress_tab.click
  end

  def then_i_see_one_content_item_which_matches_default_filters
    expect(@audit_report_page).to be_displayed
    expect(@audit_report_page).to have_content('1 Content items')
    expect(@audit_report_page).to have_no_content('2 Content items')
  end

  def when_i_export_an_audit_report
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load(content_id: Content::Item.last.content_id)
    @audit_report.export_to_csv.click
  end

  def then_i_receive_the_report_in_csv_format
    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include(
      'filename="Transformation_audit_report_CSV_download.csv"',
    )
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Example 1,https://gov.uk/example1")
  end

  def and_they_are_filtered
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load(content_id: Content::Item.last.content_id)
    @audit_report.allocated_to.select 'Anyone'
    @audit_report.organisations.select 'HMRC'
    @audit_report.apply_filters.click
  end

  def when_i_export_the_reports
    @audit_report.export_to_csv.click
  end

  def and_there_are_multiple_pages_of_unfiltered_content_items
    create_list(:content_item, 100)
  end

  def when_i_export_all_the_reports
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    click_link "Export filtered audit to CSV"
  end

  def then_i_receive_an_audit_progress_report_for_all_audits_in_csv_format
    csv = CSV.parse(page.body)
    number_of_metadata_rows = 1
    expect(csv.count).to eq(Content::Item.count + number_of_metadata_rows)
  end

  def when_i_apply_filters
    @audit_content_page = ContentAuditTool.new.audit_content_page
    @audit_report_page = ContentAuditTool.new.audit_report_page
    @audit_content_page.load
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "No one"
      form.apply_filters.click
    end
  end
end
