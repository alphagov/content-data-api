json.metadata do
  json.metric @metric_params.metric
  json.total @metrics.values.sum
  json.from @metric_params.from
  json.to @metric_params.to
  json.content_id @metric_params.content_id
end
json.results @metrics.each do |date, value|
  json.content_id @metric_params.content_id
  json.date date
  json.value value
end
