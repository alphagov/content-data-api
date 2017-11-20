RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  scenario "Exporting a csv file as an attachment" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_three_content_items
    when_i_export_an_audit_report
    then_i_receive_the_report_in_csv_format
  end

  scenario "Applying the filters to the export" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_three_content_items
    and_a_filter_is_applied_to_show_only_hmrc_content_items
    when_i_export_the_reports
    then_i_receive_only_hmrc_related_content_items_in_the_report
  end

  scenario "Multiple pages including_details_of_audit_progress_ of content items are in the database" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_multiple_pages_of_unfiltered_content_items
    when_i_export_all_the_reports
    then_i_receive_an_audit_progress_report_for_all_content_items_in_csv_format
  end

  scenario "Discard audit status filter when clicking from content view to report, and then exporting CSV" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_three_content_items
    when_i_filter_the_content_page_for_content_items_with_no_one_assigned_to_them
    then_i_see_the_two_unassigned_content_items
    when_i_navigate_to_audits_report_page
    then_i_do_not_see_the_two_unassigned_content_items
    and_i_see_the_one_content_item_assigned_to_me
  end

  def given_i_am_an_auditor_belonging_to_an_organisation
    @user = create(:user)
    @hmrc = create(:content_item,
                  title: "HMRC",
                  document_type: "organisation",
                  allocated_to: @user)
  end

  def then_i_receive_only_hmrc_related_content_items_in_the_report
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Assigned HMRC content,https://gov.uk/example1")
    expect(@audit_report).to have_no_content("Unassigned content 2,https://gov.uk/example2")
  end

  def then_i_see_the_two_unassigned_content_items
    expect(@audit_content_page).to have_no_content("Assigned HMRC content")
    expect(@audit_content_page).to have_content("Unassigned content 2")
    expect(@audit_content_page).to have_content("Unassigned content 3")
  end

  def when_i_navigate_to_audits_report_page
    @audit_report_page = ContentAuditTool.new.audit_report_page
    @audit_content_page.audits_progress_tab.click
  end

  def then_i_do_not_see_the_two_unassigned_content_items
    expect(@audit_report_page).to be_displayed
    expect(@audit_report_page.content_item_count.text).not_to eq('2')
  end

  def and_i_see_the_one_content_item_assigned_to_me
    expect(@audit_report_page.content_item_count.text).to eq('1')
  end

  def when_i_export_an_audit_report
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load
    @audit_report.export_to_csv.click
  end

  def then_i_receive_the_report_in_csv_format
    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include(
      'filename="Transformation_audit_report_CSV_download.csv"',
    )
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Assigned HMRC content,https://gov.uk/example1")
  end

  def and_a_filter_is_applied_to_show_only_hmrc_content_items
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load
    @audit_report.organisations.select 'HMRC'
    @audit_report.apply_filters.click
  end

  def when_i_export_the_reports
    @audit_report.export_to_csv.click
  end

  def and_there_are_multiple_pages_of_unfiltered_content_items
    content_items_per_page = 100
    create_list(:content_item, content_items_per_page * 2)
  end

  def when_i_export_all_the_reports
    visit audits_report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    click_link "Export filtered audit to CSV"
  end

  def then_i_receive_an_audit_progress_report_for_all_content_items_in_csv_format
    csv = CSV.parse(page.body)
    number_of_metadata_rows = 1
    expect(csv.count).to eq(Content::Item.count + number_of_metadata_rows)
  end

  def when_i_filter_the_content_page_for_content_items_with_no_one_assigned_to_them
    @audit_content_page = ContentAuditTool.new.audit_content_page
    @audit_content_page.load
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "No one"
      form.apply_filters.click
    end
  end

  def and_there_are_three_content_items
    example1 = create(:content_item,
                      title: "Assigned HMRC content",
                      base_path: "/example1",
                      allocated_to: @user,
                      primary_publishing_organisation: @hmrc)
    create(:audit, content_item: example1)
    create(:content_item,
           title: "Unassigned content 2",
           base_path: "/example2")
    create(:content_item,
           title: "Unassigned content 3",
           base_path: "/example3")
  end
end
