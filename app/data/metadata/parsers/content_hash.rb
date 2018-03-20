class Metadata::Parsers::ContentHash
  def self.parse(raw_json)
    {
      content_hash: Digest::SHA1.hexdigest(Content::Parser.extract_content(raw_json))
    }
  end
end
