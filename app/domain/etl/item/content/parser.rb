class Etl::Item::Content::Parser
  include Singleton

  def initialize
    register_parsers
  end

  def self.extract_content(*args, subpage_slug: nil)
    instance.extract_content(*args, subpage_slug: subpage_slug)
  end

  def extract_content(json, subpage_slug: nil)
    return nil if json.blank?

    schema = json.dig("schema_name")
    base_path = json.dig("base_path")
    parser = for_schema(schema)

    if parser.blank?
      GovukError.notify(InvalidSchemaError.new("Schema does not exist: #{schema}"), extra: { base_path: base_path.to_s })
      nil
    elsif parser.respond_to?(:parse_subpage)
      parse_html parser.parse_subpage(json, subpage_slug)
    else
      parse_html parser.parse(json)
    end
  rescue StandardError => e
    GovukError.notify(e, extra: { schema: schema, base_path: base_path, json: json })
  end

private

  def register_parsers
    [
      Etl::Item::Content::Parsers::BodyContent,
      Etl::Item::Content::Parsers::Contact,
      Etl::Item::Content::Parsers::EmailAlertSignup,
      Etl::Item::Content::Parsers::Finder,
      Etl::Item::Content::Parsers::FinderEmailSignup,
      Etl::Item::Content::Parsers::GenericWithLinks,
      Etl::Item::Content::Parsers::HmrcManual,
      Etl::Item::Content::Parsers::Licence,
      Etl::Item::Content::Parsers::LocalTransaction,
      Etl::Item::Content::Parsers::Mainstream,
      Etl::Item::Content::Parsers::Need,
      Etl::Item::Content::Parsers::Parts,
      Etl::Item::Content::Parsers::Place,
      Etl::Item::Content::Parsers::ServiceManualHomepage,
      Etl::Item::Content::Parsers::ServiceManualStandard,
      Etl::Item::Content::Parsers::ServiceManualServiceToolkit,
      Etl::Item::Content::Parsers::ServiceManualTopic,
      Etl::Item::Content::Parsers::ServiceSignIn,
      Etl::Item::Content::Parsers::StatisticsAnnouncement,
      Etl::Item::Content::Parsers::StepByStep,
      Etl::Item::Content::Parsers::Taxon,
      Etl::Item::Content::Parsers::Transaction,
      Etl::Item::Content::Parsers::TravelAdviceIndex,
      Etl::Item::Content::Parsers::Unpublished,
      Etl::Item::Content::Parsers::NoContent
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
