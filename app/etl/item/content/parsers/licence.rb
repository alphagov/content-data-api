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


# body = json.dig("details", "body")
# return unless body.present?
#
# if body.is_a?(Array)
#   body_by_content_type = body.map(&:values).to_h
#   body = body_by_content_type.fetch('text/html', nil)
# end
#
# body
