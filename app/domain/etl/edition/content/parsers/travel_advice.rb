class Etl::Edition::Content::Parsers::TravelAdvice
  def parse_subpage(json, subpage_path)
    if summary_page?(json, subpage_path)
      json.dig("details", "summary").find { |x| x["content_type"] == "text/html" }.try(:dig, "content")
    else
      Etl::Edition::Content::Parsers::Parts.new.parse_subpage(json, subpage_path)
    end
  end

  def schemas
    %w[travel_advice]
  end

private

  def summary_page?(json, subpage_path)
    json["base_path"] == subpage_path
  end
end
