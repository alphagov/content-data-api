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
    edition = Facts::Edition.create!(
      number_of_pdfs: Item::Metadata::NumberOfPdfs.parse(item.raw_json),
      number_of_word_files: Item::Metadata::NumberOfWordFiles.parse(item.raw_json),
      dimensions_date: Dimensions::Date.for(date),
      dimensions_item: item,
    )

    unless item.get_content.blank?
      edition.update(Item::Quality::Service.new.run(item.get_content))
    end
  end
end
