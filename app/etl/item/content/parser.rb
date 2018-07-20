class Item::Content::Parser
  include Singleton

  def initialize
    register_parsers
  end

  def self.extract_content(*args, subpage_path: nil)
    instance.extract_content(*args, subpage_path: subpage_path)
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
      Item::Content::Parsers::BodyContent,
      Item::Content::Parsers::Contact,
      Item::Content::Parsers::EmailAlertSignup,
      Item::Content::Parsers::Finder,
      Item::Content::Parsers::FinderEmailSignup,
      Item::Content::Parsers::GenericWithLinks,
      Item::Content::Parsers::HmrcManual,
      Item::Content::Parsers::Licence,
      Item::Content::Parsers::LocalTransaction,
      Item::Content::Parsers::Mainstream,
      Item::Content::Parsers::Need,
      Item::Content::Parsers::Parts,
      Item::Content::Parsers::Place,
      Item::Content::Parsers::ServiceManualHomepage,
      Item::Content::Parsers::ServiceManualStandard,
      Item::Content::Parsers::ServiceManualServiceToolkit,
      Item::Content::Parsers::ServiceManualTopic,
      Item::Content::Parsers::ServiceSignIn,
      Item::Content::Parsers::StatisticsAnnouncement,
      Item::Content::Parsers::StepByStep,
      Item::Content::Parsers::Taxon,
      Item::Content::Parsers::Transaction,
      Item::Content::Parsers::TravelAdviceIndex,
      Item::Content::Parsers::Unpublished,
      Item::Content::Parsers::NoContent
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
