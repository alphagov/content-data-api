require 'odyssey'

class Items::Importers::QualityMetrics
  attr_reader :content_quality_service, :item_id

  def self.run(*args)
    new(*args).run
  end

  def initialize(item_id, _ = {})
    @item_id = item_id
    @content_quality_service = Item::ContentQualityService.new
  end

  def run
    item = Dimensions::Item.find(@item_id)

    quality_metrics = content_quality_service.run(item.get_content)
    item.update_attributes(quality_metrics)

    # FIXME: we link edition facts to the date we created the item, but it should
    # come from the publishing API event date.
    Facts::Edition.create(
      dimensions_item: item,
      dimensions_date: Dimensions::Date.for(item.created_at.to_date),
      **quality_metrics
    )
  rescue InvalidSchemaError
    do_nothing
  end

private

  def do_nothing; end
end
