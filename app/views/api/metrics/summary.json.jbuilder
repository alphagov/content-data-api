@series.each do |series|
  json.set! series.metric_name, series.total
  json.merge! @metadata
end
