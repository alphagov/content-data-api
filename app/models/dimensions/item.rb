require 'json'

class Dimensions::Item < ApplicationRecord
  has_one :facts_edition, class_name: "Facts::Edition", foreign_key: :dimensions_item_id
  validates :content_id, presence: true

  scope :by_base_path, ->(base_path) { where('base_path like (?)', base_path) }
  scope :by_content_id, ->(content_id) { where(content_id: content_id) }
  scope :by_organisation_id, ->(organisation_id) { where(primary_organisation_content_id: organisation_id) }
  scope :by_document_type, ->(document_type) { where('document_type like (?)', document_type) }
  scope :by_locale, ->(locale) { where(locale: locale) }

  def self.by_natural_key(content_id:, locale:)
    find_by(content_id: content_id, locale: locale, latest: true)
  end

  def get_content
    return if raw_json.blank?
    Item::Content::Parser.extract_content(raw_json)
  end

  def older_than?(other)
    return true unless other

    self.publishing_api_payload_version > other.publishing_api_payload_version
  end
end

class InvalidSchemaError < StandardError;
end
