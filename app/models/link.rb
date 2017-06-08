class Link < ApplicationRecord
  PRIMARY_ORG = "primary_publishing_organisation".freeze
  ALL_ORGS = "organisations".freeze
  POLICY_AREAS = "policy_areas".freeze
  TOPICS = "topics".freeze
  TAXONS = "taxons".freeze

  belongs_to :source,
    class_name: :ContentItem,
    foreign_key: :source_content_id,
    primary_key: :content_id,
    optional: true

  belongs_to :target,
    class_name: :ContentItem,
    foreign_key: :target_content_id,
    primary_key: :content_id,
    optional: true
end
