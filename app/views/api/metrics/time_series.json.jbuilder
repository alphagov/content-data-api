@series.each do |series|
  json.set! series.metric_name do
    json.array! series.values_by_date do |value|
      json.date value.keys.first
      json.value value.values.first
    end
  end
end
