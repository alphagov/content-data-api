@series.each do |series|
  json.set! series.metric_name do
    json.array! series.time_series do |time_point|
      json.date time_point[:date]
      json.value time_point[:value]
    end
  end
end
