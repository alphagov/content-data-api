class Search
  def initialize
    self.query = Query.new
  end

  def filter_by(link_type:, target_content_ids:)
    query.filter_by(link_type: link_type, target_content_ids: target_content_ids)
  end

  def execute
    self.result = Executor.execute(query)
  end

  def content_items
    result.content_items
  end

private

  attr_accessor :query, :result
end
