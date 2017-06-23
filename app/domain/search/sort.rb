class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "Six months page views (Decending)",
                 "six_months_page_views", :desc),
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
      scope.where(
        "#{field} #{{ desc: '<=', asc: '>=' }[order]} ?",
        content_item.object.send(field)
      )
    end

  private

    attr_accessor :field, :order, :nulls
  end
end
