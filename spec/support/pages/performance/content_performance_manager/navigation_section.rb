require 'site_prism/section'

module ContentPerformanceManager
  class NavigationSection < SitePrism::Section
    element :home, '[data-test-id=home]'
    element :reports, '[data-test-id=reports]'
  end
end
