class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "Six months page views (Decending)",
                 "six_months_page_views", :desc),
        Sort.new(:page_views_asc, "Six months page views (Ascending)",
                 "six_months_page_views", :asc),
        Sort.new(:title_desc, "Title (Decending)",
                 "title", :desc),
        Sort.new(:title_asc, "Title (Ascending)",
                 "title", :asc),
        Sort.new(:public_updated_at_asc, "Last public update (Oldest first)",
                 "public_updated_at", :asc, nulls: :first),
        Sort.new(:public_updated_at_desc, "Last public update (Most recent first)",
                 "public_updated_at", :desc, nulls: :last),
      ]
    end

    attr_reader :identifier, :label

    def initialize(identifier, label, field, order, options = {})
      @identifier = identifier
      @label = label
      @field = field
      @order = order
      @nulls = options.fetch(:nulls, order == :dsc ? :first : :last)
    end

    def apply(scope)
      scope.order("#{field} #{order} NULLS #{nulls}")
    end

    def where_only_after(scope, content_item)
      field_value = content_item.object.send(field)

      if field_value.nil?
        case @nulls
        when :first
          # Can't narrow down the possibilities any more, as the field
          # value for the next item could be null, or it might not be.
          scope
        when :last
          scope.where("#{field} IS NULL")
        end
      else
        scope.where(
          "#{field} #{{ desc: '<=', asc: '>=' }[order]} ?", field_value
        )
      end
    end

  private

    attr_accessor :field, :order, :nulls
  end
end
