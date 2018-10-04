class Etl::Edition::Processor
  def self.process(*args)
    new(*args).process
  end

  def initialize(old_item, new_item, date = Date.today)
    @dimensions_date = Dimensions::Date.find_or_create(date)
    @old_item = old_item
    @new_item = new_item
  end

  def process
    create_new_edition
  end

private

  attr_reader :dimensions_date, :new_item

  def create_new_edition
    Facts::Edition.create!(
      pdf_count: Etl::Item::Metadata::NumberOfPdfs.parse(new_item.raw_json),
      doc_count: Etl::Item::Metadata::NumberOfWordFiles.parse(new_item.raw_json),
      dimensions_date: dimensions_date,
      dimensions_item: new_item,
      **quality_metrics
    )
  end

  def quality_metrics
    return {} if new_item.document_text.nil?
    result = Odyssey.flesch_kincaid_re(new_item.document_text, true)
    {
      readability: result.fetch('score'),
      chars: result.fetch('string_length'),
      sentences: result.fetch('sentence_count'),
      words: result.fetch('word_count'),
    }
  end
end
