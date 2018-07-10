class Etl::Item::Content::Parsers::ServiceSignIn
  def parse(json)
    html = []
    html << json.dig("details", "choose_sign_in", "title")
    options = json.dig("details", "choose_sign_in", "options")
    unless options.nil?
      options.each do |option|
        html << option["text"]
        html << option["hint_text"]
      end
    end
    html << json.dig("details", "create_new_account", "title")
    html << json.dig("details", "create_new_account", "body")
    html.join(" ")
  end

  def schemas
    ['service_sign_in']
  end
end
