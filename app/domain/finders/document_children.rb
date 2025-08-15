class Finders::DocumentChildren
  EDITION_COLUMNS = %w[base_path title primary_organisation_id document_type sibling_order].freeze
  AGGREGATION_COLUMNS = %w[upviews pviews useful_yes useful_no satisfaction searches feedex].freeze

  def self.call(*args)
    new(*args).results
  end

  def results
    filter_editions
      .order(sanitized_order(@sort_key, @sort_dir))
      .select(*columns)
  end

private

  def initialize(parent_edition, filters)
    @parent_edition = parent_edition
    @time_period = filters.fetch(:time_period)
    @sort_key = filters.fetch(:sort_key) || "sibling_order"
    @sort_dir = filters.fetch(:sort_direction) || "asc"
  end

  def filter_editions
    scope = @parent_edition.children
    scope = scope.or(Dimensions::Edition.where(id: @parent_edition.id))
    scope.joins(join_query)
  end

  def join_query
    "LEFT JOIN aggregations_search_#{view[:table_name]} a ON dimensions_editions.warehouse_item_id = a.warehouse_item_id"
  end

  def view
    @view ||= Finders::SelectView.new(@time_period).run
  end

  def columns
    AGGREGATION_COLUMNS + EDITION_COLUMNS.map { |c| "dimensions_editions.#{c}" }
  end

  def sanitized_order(column, direction)
    avaliable_columns = AGGREGATION_COLUMNS + EDITION_COLUMNS

    raise "Order atrribute of #{column} not permitted." unless avaliable_columns.include?(column.to_s)
    raise "Order direction of #{direction} not permitted." unless %w[ASC DESC].include?(direction.upcase)

    if column == "sibling_order"
      "#{column} #{direction} NULLS FIRST, title #{direction}"
    else
      "#{column} #{direction} NULLS LAST, sibling_order ASC NULLS FIRST"
    end
  end
end
