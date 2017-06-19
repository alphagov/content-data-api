module DropdownHelper
  def grouped_themes_and_subthemes
    Theme.all.map do |theme|
      theme = ThemeOption.new(theme)
      subthemes = theme.subthemes.map { |s| SubthemeOption.new(s) }
      options = [theme, *subthemes].map { |o| [o.name, o.value] }

      [theme.name, options]
    end
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
