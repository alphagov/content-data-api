class Etl::Aggregations::Monthly
  include Traceable

  def self.process(*args)
    new(*args).process
  end

  def initialize(date: Date.yesterday)
    @date = date
  end

  def process
    time(process: :aggregations_monthly) do
      create_month
      delete_month
      aggregate_month
    end
  end

private

  attr_reader :date, :month

  def create_month
    @month = Dimensions::Month.find_existing_or_create(date)
  end

  def delete_month
    ::Aggregations::MonthlyMetric.where(dimensions_month_id: month).delete_all
  end

  def aggregate_month
    ActiveRecord::Base.connection.execute(aggregation_query)
  end

  def from
    date.beginning_of_month
  end

  def to
    date.end_of_month
  end

  def aggregation_query
    <<~SQL
      INSERT INTO aggregations_monthly_metrics (
        dimensions_month_id,
        dimensions_edition_id,
        pviews,
        upviews,
        entrances,
        searches,
        feedex,
        satisfaction,
        useful_yes,
        useful_no,
        exits,
        updated_at,
        created_at
      )
      SELECT '#{month.id}',
        max(dimensions_edition_id),
        sum(pviews),
        sum(upviews),
        sum(entrances),
        sum(searches),
        sum(feedex),
        CASE
          WHEN ((sum(useful_yes) + sum(useful_no)) = 0) THEN NULL::double precision
          ELSE (sum(useful_yes)::double precision / ((sum(useful_yes) + sum(useful_no)))::double precision)
        END AS satisfaction,
        sum(useful_yes),
        sum(useful_no),
        sum(exits),
        now(),
        now()
      FROM facts_metrics
      INNER JOIN dimensions_dates ON dimensions_dates.date = facts_metrics.dimensions_date_id
      INNER JOIN dimensions_editions ON dimensions_editions.id = facts_metrics.dimensions_edition_id
      WHERE dimensions_date_id >= '#{from}' AND dimensions_date_id <= '#{to}'
      GROUP BY warehouse_item_id
    SQL
  end
end
