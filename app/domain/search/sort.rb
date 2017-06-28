class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "Most views",
                 "six_months_page_views", :desc),
        Sort.new(:page_views_asc, "Least views",
                 "six_months_page_views", :asc),
        Sort.new(:title_desc, "A - Z",
                 "title", :asc),
        Sort.new(:title_asc, "Z - A",
                 "title", :desc),
        Sort.new(:public_updated_at_desc, "Updated - most recently",
                 "public_updated_at", :desc, nulls: :last),
        Sort.new(:public_updated_at_asc, "Updated - least recently",
                 "public_updated_at", :asc, nulls: :first),
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
