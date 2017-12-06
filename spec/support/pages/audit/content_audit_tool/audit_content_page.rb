require "site_prism/page"

class AuditContentPage < SitePrism::Page
  set_url "/audits"

  section :filter_form, "form" do
    element :search, "[data-test-id=search]"
    element :allocated_to, "[data-test-id=allocated-to]"
    element :audit_status, "[data-test-id=audit-status]"
    element :organisations, "[data-test-id=organisations]"
    element :organisations_select, "[data-test-id=organisations-select]"
    element :organisations_input, "[data-test-id=organisations] input"
    element :add_organisations, "[data-test-id=add-organisation]"
    element :primary_orgs_label, "[data-test-id=primary-orgs-label]"
    element :primary_orgs, "[data-test-id=primary-orgs]"
    element :topics, "[data-test-id=topics]"
    element :topics_select, "[data-test-id=topics-select]"
    element :topics_input, "[data-test-id=topics] input"
    element :add_topics, "[data-test-id=add-topic]"
    element :document_type, "[data-test-id=document-type]"
    element :apply_filters, "[data-test-id=apply-filters]"
    element :audits_progress_tab, '[data-test-id=reports]'
  end

  element :pagination, ".pagination"
  element :audits_progress_tab, '[data-test-id=reports]'
  element :my_content_tab, '[data-test-id=audits]'
  element :assign_content_tab, '[data-test-id=allocations]'
end
