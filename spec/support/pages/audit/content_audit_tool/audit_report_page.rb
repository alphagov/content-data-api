require 'site_prism/page'

class AuditReportPage < SitePrism::Page
  set_url '/audits/report'

  element :report_section, '.report-section'
  element :allocated_to, '#allocated_to'
  element :apply_filters, 'input[type=submit]'
  element :content_type, '#document_type'
  element :audit_progress_bar, '[data-test-id=audit_progress_bar]'
  element :improvement_progress_bar, '[data-test-id=improvement_progress_bar]'
end
