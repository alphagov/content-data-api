class Streams::Messages::BaseMessage
  attr_reader :payload

  def initialize(payload, routing_key)
    @payload = payload
    @routing_key = routing_key
  end

  def build_attributes(base_path:, title:, document_text:, warehouse_item_id:, sibling_order: nil)
    parser = Streams::ParentChild::Parser.new
    parent_child_attrs = {
      parent_warehouse_id: parser.get_parent_id(payload),
      child_sort_order: parser.get_children_ids(payload),
    }.compact
    {
      content_id:,
      base_path:,
      title:,
      publishing_api_payload_version: @payload.fetch("payload_version"),
      document_type: @payload.fetch("document_type"),
      locale:,
      document_text:,
      first_published_at: parse_time("first_published_at"),
      primary_organisation_id: primary_organisation["content_id"],
      primary_organisation_title: primary_organisation["title"],
      primary_organisation_withdrawn: primary_organisation["withdrawn"],
      organisation_ids:,
      public_updated_at: parse_time("public_updated_at"),
      schema_name: @payload.fetch("schema_name"),
      phase: @payload.fetch("phase", nil),
      publishing_app: @payload.fetch("publishing_app", nil),
      rendering_app: @payload.fetch("rendering_app", nil),
      sibling_order:,
      analytics_identifier: @payload.fetch("analytics_identifier", nil),
      update_type: @payload.fetch("update_type", nil),
      live: false,
      warehouse_item_id:,
      withdrawn: withdrawn_notice?,
      historical: historically_political?,
    }.merge(parent_child_attrs)
  end

  def invalid?
    mandatory_fields_nil? || placeholder_schema?
  end

  def withdrawn_notice?
    @payload.dig("withdrawn_notice", "explanation").present?
  end

  def historically_political?
    historical? && political?
  end

  def content_id
    @payload["content_id"]
  end

  def locale
    @payload["locale"]
  end

  def organisation_ids
    if @payload.fetch("publishing_app", nil) == "publisher"
      @payload.fetch("expanded_links", {})
        .fetch("organisations", [])
        .map { |org| org["content_id"] }
    else
      []
    end
  end

private

  def parse_time(attribute_name)
    @payload.fetch(attribute_name, nil)
  end

  def primary_organisation
    primary_org = @payload.dig("expanded_links", "primary_publishing_organisation") || []
    primary_org.any? ? primary_org[0] : {}
  end

  def political?
    @payload.dig("details", "political") || false
  end

  def historical?
    government_current = @payload.dig(
      "expanded_links", "government", 0, "details", "current"
    )

    # Treat no government as not historical
    return false if government_current.nil?

    !government_current
  end

  def mandatory_fields_nil?
    mandatory_fields = @payload.values_at("base_path", "schema_name")
    mandatory_fields.any?(&:nil?)
  end

  def placeholder_schema?
    @payload["schema_name"].include?("placeholder")
  end
end
