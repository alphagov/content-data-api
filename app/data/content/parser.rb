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
      if parser.present?
        parse_html parser.parse(json)
      else
        GovukError.notify(InvalidSchemaError.new("Schema does not exist: #{schema}"))
      end
    end

  private

    def register_parsers
      [
        Parsers::BodyContent,
        Parsers::Contact,
        Parsers::EmailAlertSignup,
        Parsers::FinderEmailSignup,
        Parsers::GenericWithLinks,
        Parsers::Licence,
        Parsers::LocationTransaction,
        Parsers::Need,
        Parsers::Parts,
        Parsers::Place,
        Parsers::ServiceManualStandard,
        Parsers::ServiceManualServiceToolkit,
        Parsers::ServiceManualTopic,
        Parsers::ServiceSignIn,
        Parsers::StatisticsAnnouncement,
        Parsers::Taxon,
        Parsers::Transaction,
        Parsers::TravelAdviceIndex,
        Parsers::Unpublished,
        Parsers::NoContent
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
