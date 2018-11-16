class Streams::Handlers::RedirectHandler < Streams::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(attrs)
    @attrs = attrs
  end

  attr_reader :attrs, :old_edition

  def process
    old_edition = find_old_edition(attrs[:base_path])
    raise 'Redirect without a previous edition?' unless old_edition.present?

    attrs[:warehouse_item_id] = old_edition.warehouse_item_id
    update_editions [attrs: attrs, old_edition: old_edition]
  end

private

  def find_old_edition(base_path)
    Dimensions::Edition.find_by(base_path: base_path, latest: true)
  end
end
