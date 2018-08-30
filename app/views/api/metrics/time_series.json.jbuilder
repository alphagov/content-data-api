json.set! @api_request.metrics.first do
  json.array! @series do |date, value|
    json.date date
    json.value value
  end
end
