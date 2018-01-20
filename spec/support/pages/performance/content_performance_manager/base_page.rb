require 'site_prism/page'

require_relative './navigation_section'

module ContentPerformanceManager
  class BasePage < SitePrism::Page
    section :navigation, NavigationSection, 'nav[role=navigation]'
  end
end
