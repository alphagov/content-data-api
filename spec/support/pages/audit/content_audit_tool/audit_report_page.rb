require 'site_prism/page'

class AuditReportPage < SitePrism::Page
  set_url '/audits/report'

  element :report_section, '[data-test-id=report-section]'
  element :audit_status, '[data-test-id=audit-status]'
  element :allocated_to, '[data-test-id=allocated-to]'
  element :apply_filters, '[data-test-id=apply-filters]'
  element :content_type, '[data-test-id=document-type]'
  element :audit_progress_bar, '[data-test-id=audit-progress-bar]'
  element :improvement_progress_bar, '[data-test-id=improvement-progress-bar]'
  element :export_to_csv, '[data-test-id=report-export]'
  element :organisations, '[data-test-id=organisations]'
  element :content_item_count, '[data-test-id=content-item-count]'
end
