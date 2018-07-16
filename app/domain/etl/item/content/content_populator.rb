class Etl::Item::Content::ContentPopulator
  def self.process
    new.process
  end

  def process
    scope = Dimensions::Item.where(document_text: nil)
    progress_bar = ProgressBar.create(total: scope.count)
    scope.each do |item|
      item.update document_text: Etl::Item::Content::Parser.extract_content(item.raw_json)
      progress_bar.increment
    end
  end
end
