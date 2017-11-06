require_relative 'content_audit_tool/audit_content_item_page'

class ContentAuditTool
  def audit_content_item
    AuditContentItemPage.new
  end

  def audit_report_item
    AuditReportPage.new
  end
end
