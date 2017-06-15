class Search
  class RulesFilter
    attr_accessor :rules

    def initialize(rules:)
      self.rules = rules
    end

    def apply(scope)
      groups = rules.group_by(&:link_type)

      groups.inject(ContentItem.none) do |filtered_scope, (link_type, group_rules)|
        target_ids = group_rules.map(&:target_content_id)
        link_filter = LinkFilter.new(link_type: link_type, target_ids: target_ids)

        filtered_scope.or(link_filter.apply(scope))
      end
    end
  end
end
