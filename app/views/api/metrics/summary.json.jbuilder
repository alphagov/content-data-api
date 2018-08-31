@series.each do |series|
  json.set! series.metric_name do
    json.total series.total
    json.latest series.latest
  end
end
