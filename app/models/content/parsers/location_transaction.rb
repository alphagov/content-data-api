class Content::Parsers::LocationTransaction
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "need_to_know")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
Content::Parser.register('location_transaction', Content::Parsers::LocationTransaction.new)
