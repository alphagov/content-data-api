module Etl::Edition::Content::Parsers
  class Parts
    def parse_subpage(json, subpage_path)
      parts = json.dig("details", "parts")
      return if parts.nil?

      current_part = parts.find { |part| part["slug"] == subpage_path }
      return if current_part.nil?

      ContentArray.new.parse(current_part["body"])
    end

    def schemas
      %w[guide]
    end
  end
end
