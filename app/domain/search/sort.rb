class Search
  class Sort
    extend Findable

    def self.all
      [
        Sort.new(:six_months_page_views_desc, "content_items.six_months_page_views desc"),
        Sort.new(:six_months_page_views_asc, "content_items.six_months_page_views asc"),
        Sort.new(:one_month_page_views_desc, "content_items.one_month_page_views desc"),
        Sort.new(:one_month_page_views_asc, "content_items.one_month_page_views asc"),
        Sort.new(:title_desc, "content_items.title desc"),
        Sort.new(:title_asc, "content_items.title asc"),
        Sort.new(:document_type_desc, "content_items.document_type desc"),
        Sort.new(:document_type_asc, "content_items.document_type asc"),
        Sort.new(:public_updated_at_desc, "content_items.public_updated_at desc"),
        Sort.new(:public_updated_at_asc, "content_items.public_updated_at asc"),
      ]
    end

    attr_reader :identifier

    def initialize(identifier, sort_query)
      @identifier = identifier
      @sort_query = sort_query
    end

    def apply(scope)
      scope.order(sort_query)
    end

  private

    attr_accessor :sort_query
  end
end
