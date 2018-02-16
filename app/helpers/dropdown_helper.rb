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

  def allocation_options_for_select(selected = nil, include_anyone: true)
    selected = current_user.uid if selected.nil?

    additional_options = [
      ['Me', current_user.uid],
      ['No one', :no_one],
    ]

    additional_options << ['Anyone', :anyone] if include_anyone

    allocation_options = FindOrganisationUsers
                           .call(organisation_slug: current_user.organisation_slug)
                           .pluck(:name, :uid)
                           .map { |name, uid| [name.squish, uid] }
                           .reject { |_, uid| uid == current_user.uid }
                           .sort_by { |name, _| name }
                           .unshift(*additional_options)

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
