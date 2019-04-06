require 'json'


class Dimensions::Edition < ApplicationRecord
  has_one :facts_edition, class_name: "Facts::Edition", foreign_key: :dimensions_edition_id
  belongs_to :publishing_api_event, class_name: "Events::PublishingApi", foreign_key: :publishing_api_event_id
  validates :content_id, presence: true
  validates :base_path, presence: true
  validates :schema_name, presence: true
  validates :publishing_api_payload_version, presence: true
  validates :warehouse_item_id, presence: true

  scope :by_base_path, ->(base_path) { where('base_path like (?)', base_path) }
  scope :live, -> { where(live: true) }
  scope :live_by_content_id, ->(content_id, locale) { where(content_id: content_id, locale: locale, live: true) }
  scope :live_by_base_path, ->(base_paths) { where(base_path: base_paths, live: true) }
  scope :outdated_subpages, ->(content_id, locale, exclude_paths) do
    live_by_content_id(content_id, locale)
      .where.not(base_path: exclude_paths)
  end

  def self.find_latest(warehouse_item_id)
    query = <<~SQL
      SELECT a.*
      FROM dimensions_editions AS a
      INNER JOIN (
          SELECT warehouse_item_id, MAX(publishing_api_event_id) AS publishing_api_event_id
          FROM dimensions_editions
          WHERE warehouse_item_id = ?
          GROUP BY warehouse_item_id
      ) AS b ON a.warehouse_item_id = b.warehouse_item_id
      AND a.publishing_api_event_id = b.publishing_api_event_id
    SQL
    self.find_by_sql([query, warehouse_item_id]).first
  end

  def promote!(old_edition)
    if old_edition
      old_edition.deprecate!
      assign_attributes warehouse_item_id: old_edition.warehouse_item_id
    end
    update!(live: true) unless unpublished?
  end

  def deprecate!
    update!(live: false)
  end

  def unpublished?
    %w(gone vanish).include?(document_type)
  end

  def change_from?(attributes)
    assign_attributes(attributes)
    dirty = changed?
    reload
    dirty
  end

  def parent_content_id
    return '' unless document_type == 'manual_section'

    _, segment1, segment2 = base_path.split('/')
    parent_path = "/#{segment1}/#{segment2}"
    parent = Dimensions::Edition.find_by(base_path: parent_path)
    parent.content_id
  end

  def metadata
    {
      title: title,
      base_path: base_path,
      content_id: content_id,
      first_published_at: first_published_at,
      public_updated_at: public_updated_at,
      publishing_app: publishing_app,
      document_type: document_type,
      primary_organisation_title: primary_organisation_title,
      withdrawn: withdrawn,
      historical: historical,
      parent_content_id: parent_content_id
    }
  end
end
