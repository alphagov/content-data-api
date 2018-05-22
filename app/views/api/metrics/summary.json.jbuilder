json.set! @api_request.metric do
  json.total @series.values.sum
  json.latest @series.values.last
end
