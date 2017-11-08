require 'site_prism/page'

class AuditContentPage < SitePrism::Page
  set_url '/audits'

  element :allocated_to, '#allocated_to'
  element :audit_status, '[data-test=audit-status]'
  element :apply_filters, 'input[type=submit]'
  element :audits_progress_tab, '[data-test=audit_progress_tab]'
end
