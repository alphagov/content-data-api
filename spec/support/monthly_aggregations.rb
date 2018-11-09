module MonthlyAggregations
  def calculate_monthly_aggregations!
    Etl::Aggregations::Monthly.process(date: Date.today)

    12.times { |index| Etl::Aggregations::Monthly.process(date: index.month.ago) }
  end
end
