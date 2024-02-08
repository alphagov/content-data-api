class Etl::GA::ViewsAndNavigationService
  PAGE_PATH_LENGTH_LIMIT = 1500

  def self.find_in_batches(*args, **kwargs, &block)
    new.find_in_batches(*args, **kwargs, &block)
  end

  def find_in_batches(date:, batch_size: 10_000, &block)
    fetch_data(date:)
      .lazy
      .map(&:stringify_keys)
      .map(&method(:append_data_labels))
      .reject(&method(:invalid_record?))
      .each_slice(batch_size, &block)
  end

  def client
    @client ||= Etl::GA::Bigquery.build
  end

private

  def append_data_labels(hash)
    hash.merge("process_name" => "views")
  end

  def invalid_record?(data)
    URI.parse(data["page_path"]) && data["page_path"].length > PAGE_PATH_LENGTH_LIMIT
  rescue URI::InvalidURIError
    true
  end

  def fetch_data(date:)
    @fetch_data ||= client
    @date = date.strftime("%Y-%m-%d")

    query = <<~SQL
      WITH CTE1 AS (
        SELECT *
        FROM `govuk-content-data.ga4.GA4 dataform`
        WHERE the_date = @date
      )
      SELECT
        cleaned_page_location AS page_path,
        unique_page_views AS upviews,
        total_page_views AS pviews,
        the_date AS date,
      FROM CTE1
    SQL

    @fetch_data.query(query, params: { date: @date }).all
  end
end
