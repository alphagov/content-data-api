class Search
  FILTERABLE_LINK_TYPES = [
    Link::PRIMARY_ORG,
    Link::ALL_ORGS,
  ].freeze

  GROUPABLE_LINK_TYPES = [
    Link::POLICY_AREAS,
    Link::POLICIES,
    Link::PRIMARY_ORG,
    Link::ALL_ORGS,
    Link::MAINSTREAM,
    Link::TOPICS,
  ].freeze

  def initialize(query = QueryBuilder.new.build)
    @query = query
  end

  def content_items
    result.content_items
  end

  def unpaginated
    result.unpaginated
  end

  def options_for(identifier)
    result.options_for(identifier)
  end

  def self.all_link_types
    (FILTERABLE_LINK_TYPES + GROUPABLE_LINK_TYPES).uniq
  end

  def self.all_audit_status
    AuditFilter.all
  end

  def self.all_subthemes
    Subtheme.all
  end

protected

  def result
    @result ||= Executor.execute(@query)
  end
end
