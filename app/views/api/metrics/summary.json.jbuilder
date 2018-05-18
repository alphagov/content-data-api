json.set! @api_request.metric do
  json.total @metrics.values.sum
  json.latest @metrics.values.last
end
