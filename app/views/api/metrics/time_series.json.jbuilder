json.set! @api_request.metric do
  json.array! @metrics do |date, value|
    json.date date
    json.value value
  end
end
