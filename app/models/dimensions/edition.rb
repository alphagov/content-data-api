require "json"

class Dimensions::Edition < ApplicationRecord
  has_one :facts_edition, class_name: "Facts::Edition", foreign_key: :dimensions_edition_id, inverse_of: "dimensions_edition"
  belongs_to :publishing_api_event, class_name: "Events::PublishingApi", inverse_of: "dimensions_editions"
  belongs_to :parent, class_name: "Dimensions::Edition", optional: true
  has_many :children, -> { where(live: true) }, class_name: "Dimensions::Edition", foreign_key: "parent_id", inverse_of: "parent"
  validates :content_id, presence: true
  validates :base_path, presence: true
  validates :schema_name, presence: true
  validates :publishing_api_payload_version, presence: true
  validates :warehouse_item_id, presence: true

  scope :by_base_path, ->(base_path) { where("base_path like (?)", base_path) }
  scope :live, -> { where(live: true) }
  scope :live_by_content_id, ->(content_id, locale) { where(content_id:, locale:, live: true) }
  scope :live_by_base_path, ->(base_paths) { where(base_path: base_paths, live: true) }
  scope :outdated_subpages,
        lambda { |content_id, locale, exclude_paths|
          live_by_content_id(content_id, locale)
            .where.not(base_path: exclude_paths)
        }

  delegate :document_id, to: :parent, prefix: true, allow_nil: true

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
    find_by_sql([query, warehouse_item_id]).first
  end

  def promote!(old_edition)
    old_edition.update!(live: false) if old_edition
    update!(live: true) unless unpublished?
  end

  def unpublished?
    %w[gone vanish redirect].include?(document_type)
  end

  def change_from?(attributes)
    assign_attributes(attributes)
    dirty = changed?
    reload
    dirty
  end

  def document_id
    "#{content_id}:#{locale}"
  end

  def metadata
    {
      title:,
      base_path:,
      content_id:,
      locale:,
      first_published_at:,
      public_updated_at:,
      publishing_app:,
      document_type:,
      primary_organisation_title:,
      withdrawn:,
      historical:,
      parent_document_id:,
    }
  end

  def related_content_count
    child_count = children.count
    return child_count unless child_count.zero?

    parent.try(:related_content_count) || 0
  end
end
