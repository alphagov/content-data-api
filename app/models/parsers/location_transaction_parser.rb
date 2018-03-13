class Parsers::LocationTransactionParser
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "need_to_know")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
Parsers::ContentExtractors.register('location_transaction', Parsers::LocationTransactionParser.new)
