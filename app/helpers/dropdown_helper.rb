module DropdownHelper
  def taxon_options_for_select(selected = nil)
    taxon_options = Content::Item.all_taxons.pluck(:title, :content_id)

    options_for_select(taxon_options, selected)
  end

  def organisation_options_for_select(selected = nil)
    organisation_options = Content::Item
                             .all_organisations
                             .pluck(:title, :content_id)
                             .map { |title, content_id| [title.squish, content_id] }
                             .sort_by { |title, _| title }

    options_for_select(organisation_options, selected)
  end

  def sort_by_options_for_select(selected = nil)
    sort_by_options = {
      "Title A-Z" => "title_asc",
      "Title Z-A" => "title_desc",
    }

    options_for_select(sort_by_options, selected)
  end

  def document_type_options_for_select(selected = nil)
    document_type_options = Audits::Plan
                              .document_types
                              .sort_by { |key, _value| key.split(/\s>\s/) }
    options_for_select(document_type_options, selected)
  end

  def allocation_options_for_select(selected = nil)
    selected = current_user.uid if selected.nil?

    allocation_options = FindOrganisationUsers
                           .call(organisation_slug: current_user.organisation_slug)
                           .pluck(:name, :uid)
                           .map { |name, uid| [name.squish, uid] }
                           .reject { |_, uid| uid == current_user.uid }
                           .sort_by { |name, _| name }
                           .unshift(
                             ['No one', :no_one],
                             ['Me', current_user.uid],
                           )

    options_for_select(allocation_options, selected)
  end

  class ThemeOption < SimpleDelegator
    def name
      "All #{super}"
    end

    def value
      "Theme_#{id}"
    end
  end

  class SubthemeOption < SimpleDelegator
    def value
      "Subtheme_#{id}"
    end
  end
end
