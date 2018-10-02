json.metadata do
  json.merge! @metadata
end

json.time_period do
  json.from @from
  json.to @to
end

json.time_series_metrics @time_series_metrics do |series|
  json.name series.metric_name
  json.total series.total
  json.time_series series.time_series do |time_point|
    json.date time_point[:date]
    json.value time_point[:value]
  end
end
