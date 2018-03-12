json.set! @metric_params.metric do
  json.total @metrics.values.sum
  json.latest @metrics.values.last
end
