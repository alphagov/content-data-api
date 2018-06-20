class Item::Processor
  attr_reader :item, :date, :subpage

  def self.run(item, date, subpage:)
    new(item: item, date: date, subpage: subpage).run
  end

  def initialize(item:, date:, subpage:)
    @item = item
    @date = date
    @subpage = subpage
  end

  def run
    edition = Facts::Edition.create!(
      number_of_pdfs: Item::Metadata::NumberOfPdfs.parse(item.raw_json),
      number_of_word_files: Item::Metadata::NumberOfWordFiles.parse(item.raw_json),
      dimensions_date: Dimensions::Date.for(date),
      dimensions_item: item,
    )

    content = ::Item::Content::Parser.extract_content(item.raw_json, subpage: subpage)
    unless content.blank?
      edition.update(Item::Quality::Service.new.run(content))
    end
  end
end
