module TableHelper
  def sort_table_header(heading:, attribute:, filter_options:)
    SortTable.new(self, heading, attribute, filter_options).render
  end

  class SortTable
    attr_accessor :view, :heading, :attribute, :filter_options

    delegate :content_tag, :params, :link_to, :content_items_path, to: :view

    def initialize(view, heading, attribute, filter_options)
      @view = view
      @heading = heading
      @attribute = attribute
      @filter_options = filter_options
    end

    def render
      content_tag :th, "aria-sort" => aria_label do
        link text_label, order_param, filter_options
      end
    end

  private

    def link(label, order, filter_options)
      link_options = {
          sort: attribute,
          order: order
      }
      link_options.merge!(filter_options)

      link_to content_items_path(link_options) do
        "#{heading}#{content_tag :span, label, class: 'rm'}".html_safe
      end
    end

    def currently_sorted_by?
      params[:order].present? && params[:sort] == attribute
    end

    def text_label
      ", sort #{readable_sort_term(order_param)}"
    end

    def order_param
      if currently_sorted_by? && params[:order] == "asc"
        "desc"
      else
        "asc"
      end
    end

    def aria_label
      if currently_sorted_by?
        readable_sort_term(params[:order])
      else
        "none"
      end
    end

    def readable_sort_term(term)
      term_map = { "asc" => "ascending", "desc" => "descending" }
      term_map[term] || "ascending"
    end
  end
end
