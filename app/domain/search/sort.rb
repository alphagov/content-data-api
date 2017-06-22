class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:page_views_desc, "six_months_page_views", :desc),
      ]
    end

    attr_reader :identifier

    def initialize(identifier, field, order)
      @identifier = identifier
      @field = field
      @order = order
    end

    def apply(scope)
      scope.order("#{field} #{order}")
    end

  private

    attr_accessor :field, :order
  end
end
