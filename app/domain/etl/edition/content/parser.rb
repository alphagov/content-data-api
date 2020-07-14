class Etl::Edition::Content::Parser
  def initialize
    register_parsers
  end

  def self.extract_content(json, subpage_path: nil)
    new.extract_content(json, subpage_path: subpage_path)
  end

  def extract_content(json, subpage_path: nil)
    return nil if json.blank?

    schema = json.dig("schema_name")
    base_path = json.dig("base_path")
    parser = for_schema(schema)
    if parser.blank?
      GovukError.notify(InvalidSchemaError.new("Schema does not exist: #{schema}"), extra: { base_path: base_path.to_s })
      nil
    elsif parser.respond_to?(:parse_subpage)
      parse_html parser.parse_subpage(json, subpage_path)
    else
      parse_html parser.parse(json)
    end
  rescue StandardError => e
    GovukError.notify(e, extra: { schema: schema, base_path: base_path, json: json })
  end

private

  def register_parsers
    [
      ::Etl::Edition::Content::Parsers::BodyContent,
      ::Etl::Edition::Content::Parsers::Contact,
      ::Etl::Edition::Content::Parsers::EmailAlertSignup,
      ::Etl::Edition::Content::Parsers::Finder,
      ::Etl::Edition::Content::Parsers::FinderEmailSignup,
      ::Etl::Edition::Content::Parsers::GenericWithLinks,
      ::Etl::Edition::Content::Parsers::HMRCManual,
      ::Etl::Edition::Content::Parsers::Licence,
      ::Etl::Edition::Content::Parsers::LocalTransaction,
      ::Etl::Edition::Content::Parsers::Mainstream,
      ::Etl::Edition::Content::Parsers::Need,
      ::Etl::Edition::Content::Parsers::Parts,
      ::Etl::Edition::Content::Parsers::Place,
      ::Etl::Edition::Content::Parsers::ServiceManualHomepage,
      ::Etl::Edition::Content::Parsers::ServiceManualStandard,
      ::Etl::Edition::Content::Parsers::ServiceManualServiceToolkit,
      ::Etl::Edition::Content::Parsers::ServiceManualTopic,
      ::Etl::Edition::Content::Parsers::ServiceSignIn,
      ::Etl::Edition::Content::Parsers::StatisticsAnnouncement,
      ::Etl::Edition::Content::Parsers::StepByStep,
      ::Etl::Edition::Content::Parsers::Taxon,
      ::Etl::Edition::Content::Parsers::Transaction,
      ::Etl::Edition::Content::Parsers::TravelAdvice,
      ::Etl::Edition::Content::Parsers::TravelAdviceIndex,
      ::Etl::Edition::Content::Parsers::Unpublished,
      ::Etl::Edition::Content::Parsers::NoContent,
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

  class InvalidSchemaError < StandardError
  end
end
