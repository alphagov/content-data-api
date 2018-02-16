module DropdownHelper
  def taxon_options_for_select(selected = nil)
    taxon_options = Item.all_taxons.pluck(:title, :content_id)

    options_for_select(taxon_options, selected)
  end

  def organisation_options_for_select(selected = nil)
    organisation_options = Item
                           .all_organisations
                           .pluck(:title, :content_id)
                           .map { |title, content_id| [title.squish, content_id] }
                           .sort_by { |title, _| title }

    options_for_select(organisation_options, selected)
  end
end
