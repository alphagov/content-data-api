class Etl::Edition::Content::Parsers::ContentArray
  def parse(content)
    return if content.blank?
    return content unless content.is_a?(Array)

    html_content = content.find { |content_hash| content_hash["content_type"] == "text/html" }
    return if html_content.blank?

    html_content["content"]
  end
end
