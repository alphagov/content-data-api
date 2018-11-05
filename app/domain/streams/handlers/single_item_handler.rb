class Streams::Handlers::SingleItemHandler < Streams::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message, :old_edition

  def process
    attrs = message.extract_edition_attributes
    update_editions [attrs: attrs, old_edition: find_old_edition(attrs[:content_id], attrs[:locale])]
  end

private

  def find_old_edition(content_id, locale)
    Dimensions::Edition.find_by(content_id: content_id, locale: locale, latest: true)
  end
end
