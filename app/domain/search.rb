class Search
  def initialize
    self.query = Query.new
  end

  def filter_by(link_type:, source_ids: nil, target_ids: nil)
    query.filter_by(
      link_type: link_type,
      source_ids: source_ids,
      target_ids: target_ids,
    )
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
