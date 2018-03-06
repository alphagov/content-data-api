require 'json'

class Dimensions::Item < ApplicationRecord
  validates :content_id, presence: true


  scope :dirty_before, ->(date) do
    where('updated_at < ?', date).where(dirty: true)
  end

  def get_content
    json_object = raw_json
    return if json_object.blank?
    extract_by_schema_type(json_object)
  end

  def new_version
    new_version = self.dup
    new_version.assign_attributes(latest: true, dirty: false)
    new_version
  end

  def dirty!
    update_attributes!(dirty: true)
  end

  def gone!
    update_attributes(status: 'gone')
  end

  def self.create_empty(content_id, base_path)
    create(
      content_id: content_id,
      base_path: base_path,
      latest: true,
      dirty: true
    )
  end

private

  VALID_SCHEMA_TYPES = %w[
    answer
    case_study
    consultation
    corporate_information_page
    detailed_guide
    document_collection
    fatality_notice
    guide
    help
    hmrc_manual_section
    html_publication
    licence
    manual
    manual_section
    news_article
    place
    publication
    service_manual_guide
    simple_smart_answer
    specialist_document
    speech
    statistical_data_set
    take_part
    topical_event_about_page
    travel_advice
    working_group
    world_location_news_article
  ].freeze

  def extract_by_schema_type(json)
    schema = json.dig("schema_name")
    if schema.nil? || !VALID_SCHEMA_TYPES.include?(schema)
      raise InvalidSchemaError, "Schema does not exist"
    end

    case schema
    when 'licence'
      html = extract_licence(json)
    when 'place'
      html = extract_place(json)
    when 'guide', 'travel_advice'
      html = extract_parts(json)
    else
      html = extract_main(json)
    end
    parse_html(html)
  end

  def extract_licence(json)
    json.dig("details", "licence_overview")
  end

  def extract_place(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end

  def extract_parts(json)
    text = []
    html = json.dig("details")
    html["parts"].each do |part|
      text << part["title"]
      text << part["body"]
    end
    text.join(" ")
  end

  def extract_main(json)
    json.dig("details", "body")
  end

  def parse_html(html)
    return if html.nil?
    html.delete!("\n")
    Nokogiri::HTML.parse(html).text
  end
end

class InvalidSchemaError < StandardError;
end
