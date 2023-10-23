require 'pry'
require "google/cloud/bigquery"
class Etl::GA::Bigquery
  
  def self.build(date:, service:)
      new.build(date:, service:)
  end

  def build(date:, service:)
    @bigquery ||= Google::Cloud::Bigquery.new(
      project_id: ENV["BIGQUERY_PROJECT"],
      credentials: ENV["BIGQUERY_CREDENTIALS"]
    )
    # binding.pry
    @date = date.strftime('%Y-%m-%d')

    get_service_metrics(send(service.to_sym))
  end

  def get_service_metrics(service)
    puts "get_service_metrics"
    query = <<~SQL
      WITH CTE1 AS (
        SELECT *
        FROM `govuk-content-data.dataform.GA4 dataform`
        WHERE the_date = @date
      )
      #{service}
    SQL
  #  binding.pry
    results = @bigquery.query(query, params: { date: @date })
    # binding.pry
    # results.select! { |result| result[:page_path] == "/topic/personal-tax/income-tax" }
    "list BQ results "
    results.each do |row|
      puts row
    end
    results
  end

  def views_and_navigation
    <<~SQL
      SELECT
        cleaned_page_location AS page_path,
        unique_page_views AS upviews,
        page_views AS pviews,
        the_date AS date,
      FROM CTE1
      WHERE cleaned_page_location = "/topic/personal-tax/income-tax"
    SQL
  end
  # WHERE cleaned_page_location = "/topic/personal-tax/income-tax"

  # def get_views_and_navigation_results
  #   query = <<~SQL
  #     WITH CTE1 AS (
  #       SELECT *
  #       FROM `govuk-content-data.dataform.GA4 dataform`
  #       WHERE the_date = "30-10-2023"
  #       LIMIT 50
  #     )
  #     SELECT
  #       cleaned_page_location AS page_path,
  #       unique_page_views AS upviews,
  #       page_views AS pviews,
  #       ? AS entrances,
  #       ? AS exits,
  #       ? AS bounces, - needs to be an integer
  #       ? AS page_time,
  #     FROM CTE1
  #   SQL
  # end

  def user_feedback
    <<~SQL
      SELECT
        cleaned_page_location AS page_path,
        useful_yes AS useful_yes,
        useful_no AS useful_no,
        satisfaction AS satisfaction,
        the_date AS date,
      FROM CTE1
      WHERE cleaned_page_location = "/topic/personal-tax/income-tax"
    SQL
  end

  def internal_search
    <<~SQL
      SELECT
        cleaned_page_location AS page_path,
        unique_searches AS searches,
        unique_searches AS unique_searches,
        the_date AS date,
      FROM CTE1
      WHERE cleaned_page_location = "/topic/personal-tax/income-tax"
    SQL
  end
end
