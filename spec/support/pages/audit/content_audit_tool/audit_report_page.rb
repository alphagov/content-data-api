require 'site_prism/page'

class AuditReportPage < SitePrism::Page
  set_url '/audits/report'

  element :report_section, '.report-section'
  element :allocated_to, '#allocated_to'
  element :apply_filters, 'input[type=submit]'
end
