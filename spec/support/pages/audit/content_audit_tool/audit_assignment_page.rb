require "site_prism/page"

class AuditAssignmentPage < SitePrism::Page
  set_url "/audits"

  section :filter_form, "[data-test-id=allocations-sidebar]" do
    element :search, "[data-test-id=search]"
    element :allocated_to, "[data-test-id=allocated-to]"
    element :audit_status, "[data-test-id=audit-status]"
    element :organisations, "[data-test-id=organisations]"
    element :organisations_select, "[data-test-id=organisations-select]"
    element :organisations_input, "[data-test-id=organisations] input"
    element :add_organisations, "[data-test-id=add-organisation]"
    element :primary_orgs_label, "[data-test-id=primary-orgs-label]"
    element :primary_orgs, "[data-test-id=primary-orgs]"
    element :document_type, "[data-test-id=document-type]"
    element :apply_filters, "[data-test-id=apply-filters]"
    element :audits_progress_tab, '[data-test-id=reports]'
  end


  element :allocation_size, '[data-tracking-id=allocation-batch-size]'
  element :allocate_to, '[data-test-id=allocate-to]'
  element :allocate_button, '[data-test-id=allocate-button]'
  element :my_content_tab, '[data-test-id=audits]'
  element :assign_content_tab, '[data-test-id=allocations]'
  element :checkbox, '.select-content-item'
  elements :assigned_to_columns, "[data-test-id=item-assigned-to]"
end
