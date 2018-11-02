class Streams::GrowDimension
  def self.should_grow?(old_edition:, attrs:)
    new(old_edition, attrs).should_grow?
  end

  def initialize(old_edition, attrs)
    @old_edition = old_edition
    @attrs = attrs
  end

  def should_grow?
    is_new_item? || item_needs_update?
  end

private

  attr_reader :attrs, :old_edition

  def item_needs_update?
    is_new_message? && attributes_have_changed?
  end

  def attributes_have_changed?
    @old_edition.change_from? comparable_attributes
  end

  def is_new_item?
    @old_edition.nil?
  end

  def is_new_message?
    attrs[:publishing_api_payload_version].to_i > old_edition.publishing_api_payload_version
  end

  def comparable_attributes
    @attrs.reject(&method(:excluded_from_comparison?))
  end

  def excluded_from_comparison?(key, _value)
    %i[publishing_api_payload_version public_updated_at id update_at created_at latest].include? key
  end
end
