class ContentExtraction::Parsers::FinderEmailSignupParser
  def parse(json)
    html = []
    json.dig("details", "email_signup_choice").each do |choice|
      html << choice["radio_button_name"]
    end
    html << json.dig("description")
    html.join(" ")
  end
end
ContentExtraction::ContentParser.register('finder_email_signup', ContentExtraction::Parsers::FinderEmailSignupParser.new)
