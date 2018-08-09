require 'odyssey'
class Etl::Item::Processor
  attr_reader :new_item, :old_item, :dimensions_date

  def self.run(new_item, old_item, date)
    new(new_item: new_item, old_item: old_item, date: date).run
  end

  def initialize(new_item:, old_item:, date:)
    @new_item = new_item
    @old_item = old_item
    @dimensions_date = Dimensions::Date.for(date)
  end

  def run
    if content_changed?
      create_new_edition
    else
      clone_existing_edition
    end
  end

  def content_changed?
    return true unless old_item
    old_item.try(:document_text) != new_item.try(:document_text)
  end

private

  def clone_existing_edition
    old_item.facts_edition.clone_for!(new_item, dimensions_date)
  end

  def create_new_edition
    Facts::Edition.create!(
      number_of_pdfs: Etl::Item::Metadata::NumberOfPdfs.parse(new_item.raw_json),
      number_of_word_files: Etl::Item::Metadata::NumberOfWordFiles.parse(new_item.raw_json),
      dimensions_date: dimensions_date,
      dimensions_item: new_item,
      **quality_metrics
    )
  end

  def quality_metrics
    return {} if new_item.document_text.nil?
    result = Odyssey.flesch_kincaid_re(new_item.document_text, true)
    {
      readability_score: result.fetch('score'),
      string_length: result.fetch('string_length'),
      sentence_count: result.fetch('sentence_count'),
      word_count: result.fetch('word_count'),
    }
  end
end
