class Item::Content::Parsers::Contact
  def parse(json)
    html = []
    html << json.dig('details', 'description')
    html << get_email(json)
    html << get_postal(json)
    html << get_phone(json)
    html.join(" ")
  end

  def schemas
    ['contact']
  end

private

  def get_phone(json)
    html = []
    json.dig('details', 'phone_numbers').each do |phone|
      html << phone['title']
      html << phone['description']
    end
    html << json.dig('details', 'more_info_phone_number')
    html
  end

  def get_postal(json)
    html = []
    json.dig('details', 'post_addresses').each do |addr|
      html << addr['title']
      html << addr['description']
    end
    html << json.dig('details', 'more_info_post_address')
    html
  end

  def get_email(json)
    html = []
    json.dig('details', 'email_addresses').each do |addr|
      html << addr['title']
      html << addr['description']
    end
    html << json.dig('details', 'more_info_email_address')
    html
  end
end
