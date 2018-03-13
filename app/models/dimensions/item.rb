require 'json'


class Dimensions::Item < ApplicationRecord
  validates :content_id, presence: true


  scope :dirty_before, ->(date) do
    where('updated_at < ?', date).where(dirty: true)
  end

  def get_content
    return if raw_json.blank?
    extract_by_schema_type(raw_json)
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

  def extract_by_schema_type(json)
    schema = json.dig("schema_name")
    if Parsers::ContentExtractors.for_schema(schema)
      html = Parsers::ContentExtractors.for_schema(schema).parse(json)
      return parse_html(html)
    end
    raise InvalidSchemaError, "Schema does not exist: #{schema}"
  end

  def parse_html(html)
    return if html.nil?
    html.delete!("\n")
    Nokogiri::HTML.parse(html).text
  end
end

class InvalidSchemaError < StandardError;
end
