json.set! @metric_params.metric do
  json.array! @metrics do |date, value|
    json.date date
    json.value value
  end
end
