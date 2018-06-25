require 'json'

class Dimensions::Item < ApplicationRecord
  has_one :facts_edition, class_name: "Facts::Edition", foreign_key: :dimensions_item_id
  validates :content_id, presence: true
  validates :base_path, presence: true
  validates :schema_name, presence: true
  validates :publishing_api_payload_version, presence: true

  scope :by_base_path, ->(base_path) { where('base_path like (?)', base_path) }
  scope :by_content_id, ->(content_id) { where(content_id: content_id) }
  scope :by_organisation_id, ->(organisation_id) { where(primary_organisation_content_id: organisation_id) }
  scope :by_document_type, ->(document_type) { where('document_type like (?)', document_type) }
  scope :by_locale, ->(locale) { where(locale: locale) }
  scope :latest_by_content_id, ->(content_id) { where(content_id: content_id, latest: true) }
  scope :latest_by_base_path, ->(base_paths) { where(base_path: base_paths, latest: true) }
  scope :existing_latest_items, ->(content_id, base_paths) { latest_by_content_id(content_id).or(latest_by_base_path(base_paths)) }

  def newer_than?(other)
    return true unless other

    self.publishing_api_payload_version > other.publishing_api_payload_version
  end

  def promote!(old_item)
    old_item.deprecate! if old_item
    update(latest: true)
  end

  def expanded_links
    if raw_json && raw_json['expanded_links']
      raw_json['expanded_links']
    else
      {}
    end
  end

  def deprecate!
    update!(latest: false)
  end
end
