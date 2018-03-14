class ContentExtraction::Parsers::LocationTransactionParser
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "need_to_know")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('location_transaction', ContentExtraction::Parsers::LocationTransactionParser.new)
