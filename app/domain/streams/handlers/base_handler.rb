class Streams::Handlers::BaseHandler
  def update_editions(items_with_old_editions)
    items_to_grow = items_with_old_editions.keep_if do |hsh|
      Streams::GrowDimension.should_grow? old_edition: hsh[:old_edition], attrs: hsh[:attrs]
    end
    items_to_grow.each(&method(:update_edition))
  end

private

  def update_edition(hash)
    new_edition = Dimensions::Edition.new(hash[:attrs])
    new_edition.facts_edition = Etl::Edition::Processor.process(hash[:old_edition], new_edition)
    new_edition.promote!(hash[:old_edition])
  end
end
