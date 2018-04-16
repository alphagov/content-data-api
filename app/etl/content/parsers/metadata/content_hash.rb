module Content
  class Parsers::Metadata::ContentHash
    def self.parse(raw_json)
      value = if raw_json.present?
                content = Parsers::ContentParser.extract_content(raw_json)
                content.present? ? Digest::SHA1.hexdigest(content) : nil
              end

      { content_hash: value }
    end
  end
end
