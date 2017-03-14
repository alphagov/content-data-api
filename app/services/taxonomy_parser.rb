class TaxonomyParser
  def self.parse(content_item)
    if content_item[:links].is_a?(Hash)
      links = content_item[:links].deep_symbolize_keys
      links.fetch(:taxons, []).map do |taxon|
        taxon.fetch(:content_id)
      end
    else
      []
    end
  end
end
