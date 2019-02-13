class Finders::Content
  def self.call(filter:)
    raise ArgumentError unless filter.has_key?(:organisation_id) && filter.has_key?(:date_range)

    filter.assert_valid_keys :search_term, :date_range, :organisation_id, :document_type, :page, :page_size, :sort_attribute, :sort_direction

    new(filter).call
  end

  def call
    {
      results: results.map(&method(:array_to_hash)),
      page: @page,
      total_pages: results.total_pages,
      total_results: total_results
    }
  end

private

  DEFAULT_PAGE_SIZE = 100
  ALL = 'all'.freeze
  NONE = 'none'.freeze

  attr_reader :organisation_id, :document_type, :date_range, :search_term

  def initialize(filter)
    @organisation_id = filter.fetch(:organisation_id)
    @document_type = filter.fetch(:document_type)
    @search_term = parse_search_term(filter[:search_term]) if filter[:search_term]
    @page = filter[:page] || 1
    @page_size = filter[:page_size] || DEFAULT_PAGE_SIZE
    @date_range = filter.fetch(:date_range)
    @sort_attribute = filter.fetch(:sort_attribute) || 'upviews'
    @sort_direction = filter.fetch(:sort_direction) || 'desc'
  end

  def view
    @view ||= Finders::SelectView.new(date_range).run
  end

  def editions_with_facts_editions
    result = view[:model_name].all
    if organisation_id == NONE
      result = result.where('organisation_id IS NULL')
    elsif organisation_id != ALL
      result = result.where(organisation_id: organisation_id)
    end
    result = result.where('document_type = ?', document_type) if document_type

    if search_term.present?
      sql = <<~SQL
        to_tsvector('english',title) @@ plainto_tsquery('english', :search_term) or
        to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text)) @@ plainto_tsquery('english', :search_term_without_slash)
      SQL

      result = result.where(sql, search_term: search_term, search_term_without_slash: search_term.tr('/', ' '))
    end

    result
  end

  def results
    editions_with_facts_editions
      .order(sanitized_order(@sort_attribute, @sort_direction))
      .page(@page)
      .per(@page_size)
      .select(*aggregates)
  end

  def total_results
    editions_with_facts_editions
      .count
  end

  def parse_search_term(search_term)
    protocol = /http(s)?:\/\//
    domain = /(www\.)?gov\.uk/

    search_term.
      gsub(protocol, '').
      gsub(domain, '')
  end

  def sanitized_order(column, direction)
    raise "Order atrribute of #{column} not permitted." unless aggregates.include?(column.to_s)
    raise "Order direction of #{direction} not permitted." unless %w[ASC DESC].include?(direction.upcase)

    "#{column} #{direction}"
  end

  def aggregates
    %w(base_path title organisation_id document_type upviews pviews useful_yes useful_no searches feedex pdf_count words reading_time)
  end

  def array_to_hash(array)
    satisfaction_responses = array[:useful_yes].to_i + array[:useful_no].to_i
    {
      base_path: array[:base_path],
      title: array[:title],
      organisation_id: array[:organisation_id],
      document_type: array[:document_type],
      upviews: array[:upviews].to_i,
      pviews: array[:pviews].to_i,
      useful_yes: array[:useful_yes].to_i,
      useful_no: array[:useful_no].to_i,
      feedex: array[:feedex].to_i,
      satisfaction: satisfaction_responses.zero? ? nil : (array[:useful_yes].to_f / satisfaction_responses).to_f,
      satisfaction_score_responses: satisfaction_responses.to_i,
      searches: array[:searches].to_i,
      pdf_count: array[:pdf_count].to_i,
      words: array[:words].to_i,
      reading_time: array[:reading_time].to_i
    }
  end
end
