module Etl::Edition::Content::Parsers
  class Licence
    def parse(json)
      body = json.dig("details", "licence_overview")
      return if body.blank?

      if body.is_a?(Array)
        body_by_content_type = body.map(&:values).to_h
        body = body_by_content_type.fetch("text/html", nil)
      end

      body
    end

    def schemas
      %w[licence]
    end
  end
end
