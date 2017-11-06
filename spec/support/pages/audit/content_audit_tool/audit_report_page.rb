require 'site_prism/page'

class AuditReportPage < SitePrism::Page
  set_url '/audits/report'

  element :report_section, '.report-section'
end
