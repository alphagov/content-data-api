class Content::Parsers::Transaction
  def parse(json)
    html = []
    html << json.dig("details", "introductory_paragraph")
    html << json.dig("details", "start_button_text")
    html << json.dig("details", "will_continue_on")
    html << json.dig("details", "more_information")
    html.join(" ")
  end
end
Content::Parser.register('transaction', Content::Parsers::Transaction.new)
