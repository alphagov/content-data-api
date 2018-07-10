class Etl::Item::Content::ContentPopulator
  def self.process
    new.process
  end

  def process
    Dimensions::Item.where(document_text: nil).each do |item|
      item.update document_text: Etl::Item::Content::Parser.extract_content(item.raw_json)
    end
  end
end
