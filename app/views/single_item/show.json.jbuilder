json.metadata do
  json.merge! @metadata
end

json.time_period do
  json.from @from
  json.to @to
end

json.metrics @series do |series|
  json.name series.metric_name
  json.total series.total
  json.time_series series.values_by_date do |value|
    json.date value.keys.first
    json.value value.values.first
  end
end

