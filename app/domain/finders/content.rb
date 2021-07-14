class Finders::Content
  include SpecificMonths

  def self.call(filter:)
    new(filter).call
  end

  def call
    {
      results: results.map(&method(:array_to_hash)),
      page: @page,
      total_pages: results.total_pages,
      total_results: total_results,
    }
  end

private

  DEFAULT_PAGE_SIZE = 100
  ALL = "all".freeze
  NONE = "none".freeze

  def initialize(filter)
    raise ArgumentError unless
      filter.key?(:organisation_id) && filter.key?(:date_range)

    filter.assert_valid_keys(
      :search_term,
      :date_range,
      :organisation_id,
      :document_type,
      :page,
      :page_size,
      :sort_attribute,
      :sort_direction,
    )

    @filter = filter

    @page = filter[:page] || 1
    @page_size = filter[:page_size] || DEFAULT_PAGE_SIZE
    @date_range = filter.fetch(:date_range)
    @sort_attribute = filter.fetch(:sort_attribute) || "upviews"
    @sort_direction = filter.fetch(:sort_direction) || "desc"
  end

  def view
    @view ||= Finders::SelectView.new(@date_range).run
  end

  def apply_filter
    scope = view[:model_name].all
    scope = find_by_month(scope) if SpecificMonths::VALID_SPECIFIC_MONTHS.include?(@date_range)
    scope = find_by_search_term(scope) if @filter[:search_term].present?
    scope = find_by_document_type(scope) if @filter[:document_type].present?
    find_by_organisation(scope)
  end

  def find_by_month(scope)
    month, year = @date_range.split("-")
    month_num = Date::MONTHNAMES.index(month.capitalize)
    month_id = sprintf("%s-%02d", year, month_num)

    scope = scope.where("#{view[:table_name]}.dimensions_month_id = '#{month_id}'")
    scope = scope.joins("JOIN dimensions_editions ON #{view[:table_name]}.dimensions_edition_id = dimensions_editions.id")
    scope.joins("JOIN facts_editions ON #{view[:table_name]}.dimensions_edition_id = facts_editions.dimensions_edition_id")
  end

  def find_by_search_term(scope)
    search_term = parse_search_term(@filter[:search_term])

    sql = <<~SQL
      to_tsvector('english',title) @@ plainto_tsquery('english', :search_term) or
      to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text)) @@ plainto_tsquery('english', :search_term_without_slash)
    SQL

    scope.where(sql, search_term: search_term, search_term_without_slash: search_term.tr("/", " "))
  end

  def find_by_document_type(scope)
    document_type = @filter.fetch(:document_type)

    if document_type == ALL
      scope
    else
      scope.where("document_type = ?", document_type)
    end
  end

  def find_by_organisation(scope)
    organisation_id = @filter.fetch(:organisation_id)

    if organisation_id == NONE
      scope = scope.where("primary_organisation_id IS NULL")
    elsif organisation_id != ALL && organisation_id.present?
      scope = scope.where(
        "primary_organisation_id = ? OR ? = ANY (organisation_ids)",
        organisation_id,
        organisation_id,
      )
    end
    scope
  end

  def results
    apply_filter
      .order(sanitized_order(@sort_attribute, @sort_direction))
      .page(@page)
      .per(@page_size)
      .select(*aggregates)
  end

  def total_results
    apply_filter.count
  end

  def parse_search_term(search_term)
    protocol = /http(s)?:\/\//
    domain = /(www\.)?gov\.uk/

    search_term
      .gsub(protocol, "")
      .gsub(domain, "")
  end

  def sanitized_order(column, direction)
    raise "Order atrribute of #{column} not permitted." unless aggregates.include?(column.to_s)
    raise "Order direction of #{direction} not permitted." unless %w[ASC DESC].include?(direction.upcase)

    "#{column} #{direction} NULLS LAST, warehouse_item_id #{direction}"
  end

  def aggregates
    %w[base_path title primary_organisation_id document_type upviews pviews useful_yes useful_no satisfaction searches feedex pdf_count words reading_time]
  end

  def array_to_hash(array)
    {
      base_path: array[:base_path],
      title: array[:title],
      # TODO: Remove this once the Content Data Admin is using the
      # primary_organisation_id value.
      organisation_id: array[:primary_organisation_id],
      primary_organisation_id: array[:primary_organisation_id],
      document_type: array[:document_type],
      upviews: array[:upviews],
      pviews: array[:pviews],
      useful_yes: array[:useful_yes],
      useful_no: array[:useful_no],
      feedex: array[:feedex],
      satisfaction: array[:satisfaction],
      searches: array[:searches],
      pdf_count: array[:pdf_count],
      words: array[:words],
      reading_time: array[:reading_time],
    }
  end
end
