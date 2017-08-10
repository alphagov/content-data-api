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
      [
        AuditStatusOption.new(Audits::Audit::AUDITED),
        AuditStatusOption.new(Audits::Audit::NON_AUDITED),
      ],
      :value,
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

  def allocation_options
    options = { "Me" => current_user.uid, "No one" => :no_one }

    options_for_select(options, params[:allocated_to])
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
      document_type.titleize
    end

    def value
      document_type
    end
  end

  class AuditStatusOption < SimpleDelegator
    def name
      to_s.titleize
    end

    def value
      to_s
    end
  end
end
