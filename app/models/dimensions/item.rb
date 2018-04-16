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

  def copy_to_new_outdated_version!(current_base_path)
    # Create a new version of this content item, assuming that a document's
    # content_id and locale are fixed, but the base_path may change.
    #
    # Outdated means that quality metrics and content details we store on the dimension
    # are missing and need to be updated.
    #
    # At the moment we populate these from a snapshot of the content item overnight.
    # The concept of "outdated" will go away when we populate content item data directly
    # from the publishing api consumer.
    #
    # This method is only expected to be called on the latest version of an item per day.
    raise "Tried to create a new outdated version but this version is not the latest" unless latest

    new_version = Dimensions::Item.create_empty(
      content_id: content_id,
      base_path: current_base_path,
      locale: locale
    )

    update_attributes(latest: false)

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
