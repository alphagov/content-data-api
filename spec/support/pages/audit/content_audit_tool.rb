require_relative 'content_audit_tool/audit_content_item_page'

class ContentAuditTool
  def audit_content_item
    AuditContentItemPage.new
  end

  def audit_content_page
    AuditContentPage.new
  end

  def audits_filter_list
    AuditsFilterList.new
  end

  def audit_report_page
    AuditReportPage.new
  end

  def audit_assignment_page
    AuditAssignmentPage.new
  end
end
