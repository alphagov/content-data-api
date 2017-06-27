module DropdownHelper
  def theme_and_subtheme_options
    groups = Theme.all.map do |theme|
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

  def link_type_options(link_type)
    options = @search.options_for(link_type).order(:title)

    options_from_collection_for_select(
      options,
      :content_id,
      :title_with_count,
      selected: params[link_type],
    )
  end

  def document_type_options
    options = @search.options_for(:document_type)
    options = options.map { |o| DocumentTypeOption.new(o) }

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
      "#{first.titleize} (#{second})"
    end

    def value
      first
    end
  end
end
