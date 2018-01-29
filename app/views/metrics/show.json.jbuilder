json.metadata do
  json.metric @metric
  json.total @metrics.values.sum
  json.from @from
  json.to @to
  json.content_id @content_id
end
json.results @metrics.each do |date, value|
  json.content_id @content_id
  json.date date
  json.value value
end
