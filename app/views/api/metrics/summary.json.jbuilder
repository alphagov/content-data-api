@series.each do |series|
  json.set! series.metric_name, series.total
end
