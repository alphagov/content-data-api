class Importers::Organisation
  attr_reader :slug, :batch, :start
  attr_writer :start

  def initialize(slug, batch: 10, start: 0)
    @slug = slug
    @batch = batch
    @start = start
  end

  def run
    @organisation = ::Organisation.find_or_create_by(slug: slug)

    Clients::SearchAPI.new.fetch(slug, batch: batch, start: start) do |content_item_attributes|
      organisation_title = get_organisation_titles(content_item_attributes)

      if @organisation.title.blank?
        add_organisation_title(organisation_title)
      end

      content_id = content_item_attributes['content_id']
      link = content_item_attributes['link']

      if content_id.present?
        content_store_attributes = Clients::ContentStore.new.fetch(link, CONTENT_STORE_FIELDS)

        attributes = content_item_attributes.slice(*CONTENT_ITEM_FIELDS)
                       .merge(content_store_attributes)

        create_or_update_content_item(content_id, attributes)
      else
        log("There is not content_id for #{slug}")
      end
    end
    raise 'No result for slug' if @organisation.content_items.empty?
  end

  def add_organisation_title(title)
    @organisation.update!(title: title)
  end

private

  CONTENT_ITEM_FIELDS = %w(content_id link title).freeze
  CONTENT_STORE_FIELDS = %w(public_updated_at document_type).freeze

  private_constant :CONTENT_ITEM_FIELDS

  def content_item_end_point(base_path)
    "https://www.gov.uk/api/content#{base_path}"
  end

  def log(message)
    unless Rails.env.test?
      Logger.new(STDOUT).warn(message)
    end
  end

  def get_organisation_titles(attributes)
    attributes['organisations'].first['title']
  end

  def create_or_update_content_item(content_id, attributes)
    content_item = @organisation.content_items.find_by(content_id: content_id)

    if content_item.blank?
      create_content_item(attributes)
    else
      update_content_item(content_item, attributes)
    end
  end

  def create_content_item(attributes)
    @organisation.content_items << ContentItem.new(attributes)
  end

  def update_content_item(content_item, attributes)
    content_item.update!(attributes)
  end
end
