module Content
  class Query
    def initialize
      @scope = ContentItem.all
      @page = 1
      @per_page = 25
      @sort = :six_months_page_views
      @sort_direction = :desc
    end

    def page(page)
      set(:page, page)
    end

    def per_page(per_page)
      set(:per_page, per_page)
    end

    def sort(sort)
      set(:sort, sort)
    end

    def sort_direction(sort_direction)
      set(:sort_direction, sort_direction)
    end

    def title(title)
      builder(verify_presence: title) do
        @scope = @scope.where("title like ?", "%#{title}%")
      end
    end

    def document_type(document_type)
      builder(verify_presence: document_type) do
        @scope = @scope.where(document_type: document_type)
      end
    end

    def primary_organisation(organisation)
      builder(verify_presence: organisation) do
        apply_link_filter(
          link_type: Link::PRIMARY_ORG,
          target_ids: organisation,
        )
      end
    end

    def organisations(organisations, primary = false)
      builder(verify_presence: organisations) do
        if primary
          primary_organisation(organisations)
        else
          apply_link_filter(
            link_type: Link::ALL_ORGS,
            target_ids: organisations,
          )
        end
      end
    end

    def taxons(taxons)
      builder(verify_presence: taxons) do
        apply_link_filter(
          link_type: Link::TAXONOMIES,
          target_ids: taxons,
        )
      end
    end

    def theme(identifier)
      builder(verify_presence: identifier) do
        type, id = identifier.to_s.split("_")
        return self unless %(Theme Subtheme).include?(type)

        model = Audits.const_get(type).find(id)
        filter = Search::RulesFilter.new(rules: model.inventory_rules)
        @scope = filter.apply(@scope)
      end
    end

    def scope
      @scope = @scope
        .order(
          @sort => @sort_direction,
          # Finally sort by base path (which is unique) to stabilise sort order
          :base_path => :asc,
        )
        .page(@page)
        .per(@per_page)
    end

  private

    def apply_link_filter(link_type:, source_ids: nil, target_ids: nil)
      filter = Search::LinkFilter.new(
        link_type: link_type,
        source_ids: source_ids,
        target_ids: target_ids,
      )

      @scope = filter.apply(@scope)
    end

    def set(instance_variable, value)
      builder(verify_presence: value) do
        instance_variable_set("@#{instance_variable}", value)
      end
    end

    def builder(verify_presence:)
      yield if verify_presence.present?
      self
    end
  end
end
