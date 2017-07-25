class Search
  class QueryBuilder
    def self.from_query(query)
      clone = query.build.deep_clone
      QueryBuilder.new
        .filters(clone.filters)
        .page(clone.page)
        .per_page(clone.per_page)
        .sort(clone.sort.identifier)
        .after(clone.previous_content_item)
    end

    def initialize
      @filters = []
      @page = 1
      @per_page = 25
      @sort = Sort.find(:page_views_desc)
      @after = nil
    end

    def page(page)
      @page = [page.to_i, 1].max
      self
    end

    def per_page(per_page)
      @per_page = [per_page.to_i, 100].min
      self
    end

    def sort(sort)
      @sort = Sort.find(sort)
      self
    end

    def audit_status(identifier)
      @filters.push(AuditFilter.find(identifier))
      self
    end

    def audited
      audit_status(:audited)
    end

    def non_audited
      audit_status(:non_audited)
    end

    def passing(is_passing = true)
      @filters.push(PassingFilter.new(is_passing))
      self
    end

    def not_passing
      passing(false)
    end

    def theme(identifier)
      type, id = identifier.to_s.split('_')
      return self unless %(Theme Subtheme).include?(type)

      model = type.constantize.find(id)
      @filters.push(RulesFilter.new(rules: model.inventory_rules))
      self
    end

    def document_type(document_type)
      @filters.push(DocumentTypeFilter.new(document_type))
      self
    end

    def filter_by(link_type:, source_ids: nil, target_ids: nil)
      filter = LinkFilter.new(
        link_type: link_type,
        source_ids: source_ids,
        target_ids: target_ids,
      )

      raise_if_already_filtered_by_link_type(filter)
      raise_if_mixing_source_and_target(filter)

      @filters.push(filter)
      self
    end

    def filters(filters)
      @filters = filters
      self
    end

    def after(content_item)
      @after = content_item
      self
    end

    def build
      Search::Query.new(@filters, @per_page, @page, @sort, @after)
    end

  private

    def raise_if_already_filtered_by_link_type(filter)
      if link_filters.any? { |f| f.link_type == filter.link_type }
        raise FilterError, "duplicate filter for #{filter.link_type}"
      end
    end

    def raise_if_mixing_source_and_target(filter)
      if link_filters.any? { |f| f.by_source? != filter.by_source? }
        raise FilterError, "attempting to filter by source and target"
      end
    end

    def link_filters
      @filters.select { |f| f.is_a?(LinkFilter) }
    end

    class ::FilterError < StandardError;
    end
  end
end
