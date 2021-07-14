class Streams::Handlers::SingleItemHandler < Streams::Handlers::BaseHandler
  class MissingLocaleError < StandardError
  end

  def self.process(*args)
    new(*args).process
  end

  def initialize(attrs, payload, routing_key)
    super()
    @attrs = attrs
    @payload = payload
    @routing_key = routing_key
  end

  attr_reader :attrs, :old_edition

  def process
    update_editions [attrs: attrs, old_edition: find_old_edition(attrs[:warehouse_item_id], attrs[:locale])]
  end

  def reprocess
    existing_edition = find_old_edition(attrs[:warehouse_item_id], attrs[:locale])
    update_existing_edition(attrs.except(:live), existing_edition)
  end

private

  def find_old_edition(warehouse_item_id, locale)
    raise MissingLocaleError unless locale

    Dimensions::Edition.find_latest(warehouse_item_id)
  end
end
