module DropdownHelper
  def theme_and_subtheme_options
    groups = Audits::Theme.all.map do |theme|
      options = [ThemeOption.new(theme)]
      options += theme.subthemes.map { |s| SubthemeOption.new(s) }

      [theme.name, options.map { |o| [o.name, o.value] }]
    end

    grouped_options_for_select(groups, params[:theme])
  end

  def audit_status_options
    options_from_collection_for_select(
      Search.all_audit_status,
      :identifier,
      :name,
      params[:audit_status],
    )
  end

  def taxons_options
    options = ContentItem.all_taxons

    options_from_collection_for_select(
      options,
      :content_id,
      :title,
      selected: params["taxons"],
    )
  end

  def organisation_options
    options = ContentItem.all_organisations

    options_from_collection_for_select(
      options,
      :content_id,
      :title,
      selected: params[:organisations],
    )
  end

  def document_type_options
    options = ContentItem
      .all_document_types
      .map { |option| DocumentTypeOption.new(option) }

    options_from_collection_for_select(
      options,
      :value,
      :name,
      params[:document_type],
    )
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

  class DocumentTypeOption < SimpleDelegator
    def name
      document_type.titleize.to_s
    end

    def value
      document_type
    end
  end
end
