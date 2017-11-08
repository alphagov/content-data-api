require "site_prism/page"

class AuditContentPage < SitePrism::Page
  set_url "/audits"

  section :filter_form, "form" do
    element :search, "[data-test=search]"
    element :allocated_to, "[data-test=allocated-to]"
    element :audit_status, "[data-test=audit-status]"
    element :organisations, "[data-test=organisations]"
    element :organisations_select, "[data-test=organisations-select]"
    element :organisations_input, "[data-test=organisations] input"
    element :add_organisations, "[data-test=add-organisation]"
    element :primary_orgs_label, "[data-test=primary-orgs-label]"
    element :primary_orgs, "[data-test=primary-orgs]"
    element :document_type, "[data-test=document-type]"
    element :apply_filters, "[data-test=apply-filters]"
  end

  element :list, "[data-test=filter-list]"
  element :listing, "[data-test=filter-list] tbody tr"
  element :pagination, ".pagination"
end
