require "site_prism/page"

class FilterAuditListPage < SitePrism::Page
  set_url "/audits"

  section :filter_form, "form" do
    element :search, ".search"
    element :allocated_to, ".allocated-to"
    element :audit_status, ".audit-status"
    element :document_type, ".document-type"
    element :organisations, ".organisation-select-wrapper"
    element :organisations_select, "#organisations-select"
    element :organisations_input, "#organisations"
    element :add_organisations, ".add-organisation"
    element :primary_orgs_label, "label[for='primary']"
    element :primary_orgs, ".primary-orgs"
    element :apply_filters, ".apply-filters"
  end

  element :list, ".filter-list"
  element :listing, ".filter-list tbody tr"
  element :pagination, ".pagination"
end
