class Etl::GA::UserFeedbackService
  def self.find_in_batches(*args, **kwargs, &block)
    new.find_in_batches(*args, **kwargs, &block)
  end

  def find_in_batches(date:, batch_size: 10_000, &block)
    fetch_data(date:)
      .lazy
      .map(&:stringify_keys)
      .map(&method(:append_labels))
      .each_slice(batch_size, &block)
  end

  def client
    @client ||= Etl::GA::Bigquery.build
  end

private

  def append_labels(hash)
    hash.merge("process_name" => "user_feedback")
  end

  def fetch_data(date:)
    @fetch_data = client
    @date = date.strftime("%Y-%m-%d")

    query = <<~SQL
      WITH CTE1 AS (
        SELECT *
        FROM `govuk-content-data.ga4.GA4 dataform`
        WHERE the_date = @date
      )
      SELECT
        cleaned_page_location AS page_path,
        useful_yes,
        useful_no,
        the_date AS date,
      FROM CTE1
    SQL

    @fetch_data.query(query, params: { date: @date }).all
  end
end
