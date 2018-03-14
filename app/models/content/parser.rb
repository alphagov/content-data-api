module Content
  class Parser
    include Singleton

    def initialize
      register_parsers
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

  private

    def register_parsers
      [
        Parsers::BodyContent,
        Parsers::Contact,
        Parsers::EmailAlertSignup,
        Parsers::FinderEmailSignup,
        Parsers::Licence,
        Parsers::LocationTransaction,
        Parsers::Need,
        Parsers::Parts,
        Parsers::Place,
        Parsers::ServiceManualStandard,
        Parsers::ServiceManualServiceToolkit,
        Parsers::ServiceManualTopic,
        Parsers::StatisticsAnnouncement,
        Parsers::Taxon,
        Parsers::Transaction,
        Parsers::Unpublished
      ].each(&method(:register_parser))
    end

    def register_parser(parser_class)
      parser = parser_class.new
      parser.schemas.each do |schema|
        register schema, parser
      end
    end

    def register(schema_name, parser)
      parsers[schema_name] = parser
    end

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
end
