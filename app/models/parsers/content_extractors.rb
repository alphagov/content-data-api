module Parsers
  class ContentExtractors
    include Singleton

    def self.register(*args)
      instance.register(*args)
    end

    def self.extract_content(*args)
      instance.extract_content(*args)
    end

    def extract_content(json)
      schema = json.dig("schema_name")
      parser = for_schema(schema)
      raise InvalidSchemaError, "Schema does not exist: #{schema}" unless parser
      parse_html parser.parse(json)
    end

    def register(schema_name, parser)
      parsers[schema_name] = parser
    end

  private

    def for_schema(schema_name)
      parsers[schema_name]
    end

    def parse_html(html)
      return if html.nil?
      html.delete!("\n")
      Nokogiri::HTML.parse(html).text
    end

    def parsers
      @parsers ||= {}
    end
  end

  Dir[File.dirname(__FILE__) + '/*.rb'].each { |file| require file }
end
