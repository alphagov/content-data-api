require "site_prism/page"

class AuditListingSection < SitePrism::Section
  element :title, "[data-test-id=title] a"
  element :page_views, "[data-test-id=page-views]"
end
