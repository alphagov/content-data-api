json.set! @api_request.metrics.first do
  json.total @series.values.sum
  json.latest @series.values.last
end
