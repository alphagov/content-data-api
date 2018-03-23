require 'json'

class Dimensions::Item < ApplicationRecord
  validates :content_id, presence: true


  scope :outdated_before, ->(date) do
    where('updated_at < ?', date).where(outdated: true)
  end

  def get_content
    return if raw_json.blank?
    Content::Parser.extract_content(raw_json)
  end

  def new_version
    new_version = self.dup
    new_version.assign_attributes(latest: true, outdated: false)
    new_version
  end

  def outdate!
    update_attributes!(outdated: true, outdated_at: Time.zone.now)
  end

  def gone!
    update_attributes(status: 'gone')
  end

  def self.create_empty(content_id, base_path)
    create(
      content_id: content_id,
      base_path: base_path,
      latest: true,
      outdated: true
    )
  end
end

class InvalidSchemaError < StandardError;
end
