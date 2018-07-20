class Etl::Item::Content::Parsers::Parts
  def parse_subpage(json, subpage_slug)
    parts = json.dig("details", "parts")
    return if parts.nil?

    current_part = parts.find { |part| part["slug"] == subpage_path }
    return if current_part.nil?

    body = current_part["body"]

    if body.is_a?(Array)
      body_by_content_type = body.map(&:values).to_h
      body = body_by_content_type.fetch('text/html', nil)
    end

    body
  end

  def schemas
    %w[guide travel_advice]
  end

private


end
