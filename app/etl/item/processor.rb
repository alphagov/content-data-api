class Item::Processor
  attr_reader :item, :date

  def self.run(item, date)
    new(item: item, date: date).run
  end

  def initialize(item:, date:)
    @item = item
    @date = date
  end

  def run
    attributes = Item::Quality::Service.new.run(item.get_content)
    attributes.merge!(
      number_of_pdfs: Item::Metadata::NumberOfPdfs.parse(item.raw_json),
      number_of_word_files: Item::Metadata::NumberOfWordFiles.parse(item.raw_json),
      dimensions_date: Dimensions::Date.for(date),
      dimensions_item: item,
    )

    Facts::Edition.create!(attributes)
  end
end
