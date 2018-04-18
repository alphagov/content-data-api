require 'json'

class Dimensions::Item < ApplicationRecord
  include Concerns::Outdateable

  validates :content_id, presence: true

  def self.by_natural_key(content_id:, locale:)
    find_by(content_id: content_id, locale: locale, latest: true)
  end

  def get_content
    return if raw_json.blank?
    Item::Content::Parser.extract_content(raw_json)
  end

  def new_version
    new_version = self.dup
    new_version.assign_attributes(latest: true, outdated: false)
    new_version
  end

  def gone!
    update_attributes(status: 'gone')
  end

  def quality_metrics_required?(attributes)
    attributes[:locale] == 'en' && attributes[:content_hash] != content_hash
  end

  def self.create_empty(content_id:, base_path:, locale:)
    create(
      content_id: content_id,
      base_path: base_path,
      locale: locale,
      latest: true,
      outdated: true,
      outdated_at: Time.zone.now
    )
  end
end

class InvalidSchemaError < StandardError;
end
