module DropdownHelper
  def theme_and_subtheme_options_for_select
    groups = Audits::Theme.all.map do |theme|
      options = [ThemeOption.new(theme)]
      options += theme.subthemes.map { |s| SubthemeOption.new(s) }

      [theme.name, options.map { |o| [o.name, o.value] }]
    end

    grouped_options_for_select(groups, params[:theme])
  end

  def audit_status_options_for_select
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

  def taxon_options_for_select
    options = Content::Item.all_taxons

    options_from_collection_for_select(
      options,
      :content_id,
      :title,
      selected: params["taxons"],
    )
  end

  def organisation_options_for_select
    options = Content::Item.all_organisations

    options_from_collection_for_select(
      options,
      :content_id,
      :title,
      selected: params[:organisations],
    )
  end

  def sort_by_options_for_select
    options = {
      "Title A-Z" => "title_asc",
      "Title Z-A" => "title_desc",
    }

    options_for_select(options, params[:sort_by])
  end

  def document_type_options_for_select
    options = Audits::Plan
                .document_types
                .sort_by { |key, _value| key.split(/\s>\s/) }

    options_for_select(options, params[:document_type])
  end

  def allocated_to_options_for_select
    options = { "Me" => current_user.uid, "No one" => :no_one }

    options_for_select(options, params[:allocated_to])
  end

  def allocate_to_options_for_select
    options = { "Me" => current_user.uid, "No one" => :no_one }

    options_for_select(options, params[:allocate_to])
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

  class AuditStatusOption < SimpleDelegator
    def name
      to_s.titleize
    end

    def value
      to_s
    end
  end
end
