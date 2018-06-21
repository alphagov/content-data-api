class Item::Content::Parsers::Licence
  def parse(json)
    parsed = json.dig("details", "licence_overview")
    if parsed.present? && parsed.is_a?(Array)
      parsed = Hash[*parsed.map(&:values).flatten].fetch("text/html", nil)
    end

    return nil unless parsed.present?
    parsed
  end

  def schemas
    ['licence']
  end
end
