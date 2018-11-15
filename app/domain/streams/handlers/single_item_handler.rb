class Streams::Handlers::SingleItemHandler < Streams::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(attrs)
    @attrs = attrs
  end

  attr_reader :attrs, :old_edition

  def process
    update_editions [attrs: attrs, old_edition: find_old_edition(attrs[:content_id], attrs[:locale], attrs[:base_path])]
  end

private

  def find_old_edition(content_id, locale, base_path)
    if locale
      Dimensions::Edition.find_by(content_id: content_id, locale: locale, latest: true)
    else
      Dimensions::Edition.find_by(content_id: content_id, base_path: base_path, latest: true)
    end
  end
end
