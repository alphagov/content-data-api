class Search
  def initialize
    self.query = Query.new
  end

  def audit_status=(identifier)
    query.audit_status = identifier
  end

  def filter_by(link_type:, source_ids: nil, target_ids: nil)
    query.filter_by(link_type, source_ids, target_ids)
  end

  def execute
    self.result = Executor.execute(query)
    nil
  end

  def content_items
    result.content_items
  end

  def per_page=(value)
    query.per_page = value
  end

  def per_page
    query.per_page
  end

  def page
    query.page
  end

  def page=(value)
    query.page = value
  end

  def sort=(identifier)
    query.sort = identifier
  end

  def sort
    query.sort
  end

  def self.all_audit_status
    AuditFilter.all
  end

private

  attr_accessor :query, :result
end
