require 'odyssey'

class Items::Importers::ContentDetails
  include Concerns::Traceable

  attr_reader :id, :date

  def self.run(id, day, month, year, *_args, **_options)
    new(id, date: Date.new(year, month, day)).run
  end

  def initialize(id, date:)
    @id = id
    @date = date
  end

  def run
    item = Dimensions::Item.find(id)
    attributes = Item::Metadata::Parser.parse(item.raw_json)

    edition_attributes = attributes.extract!(:number_of_pdfs, :number_of_word_files)

    needs_quality_metrics = item.quality_metrics_required?(attributes)
    item.update_attributes(attributes)

    edition_attributes[:dimensions_date] = Dimensions::Date.for(date)
    item.create_facts_edition!(edition_attributes)

    Items::Jobs::ImportQualityMetricsJob.perform_async(item.id) if needs_quality_metrics
  end
end
