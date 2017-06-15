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

  def initialize
    self.query = Query.new
  end

  def audit_status=(identifier)
    query.audit_status = identifier
  end

  def theme=(identifier)
    query.theme = identifier
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

  def options_for(link_types)
    link_types.map { |t| [t, result.options_for(t)] }.to_h
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

  def self.all_themes_and_subthemes
    Theme.all.map do |theme|
      options = [theme, *theme.subthemes].map do |o|
        [o.option_name, o.option_value]
      end

      [theme.name, options]
    end
  end

private

  attr_accessor :query, :result
end
