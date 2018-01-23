module TableHelper
  def sort_table_header(heading:, attribute:)
    SortTable.new(self, heading, attribute).render
  end

  class SortTable
    attr_accessor :view, :heading, :attribute

    delegate :content_tag, :params, :link_to, :items_path, to: :view

    def initialize(view, heading, attribute)
      @view = view
      @heading = heading
      @attribute = attribute
    end

    def render
      content_tag :th, class: aria_label do
        header_link inversed_order
      end
    end

  private

    def header_link(order)
      link_options = view.filter_params.merge(
        sort: attribute,
        order: order
      )

      link_to items_path(link_options) do
        "#{heading}#{content_tag :span, '', class: 'rm'}".html_safe
      end
    end

    def inversed_order
      sorting_enabled? && params[:order] == "asc" ? "desc" : "asc"
    end

    def aria_label
      sorting_enabled? ? params[:order] : "none"
    end

    def sorting_enabled?
      params[:order].present? && params[:sort] == attribute
    end
  end
end
