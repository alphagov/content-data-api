require_relative 'content_audit_tool/audit_content_item_page'

class ContentAuditTool
  def audit_content_item
    AuditContentItemPage.new
  end

  def filter_audit_list_page
    FilterAuditListPage.new
  end
end
