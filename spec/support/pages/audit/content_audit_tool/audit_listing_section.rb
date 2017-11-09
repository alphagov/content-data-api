require "site_prism/page"

class AuditListingSection < SitePrism::Section
  element :title, "[data-test=title] a"
  element :page_views, "[data-test=page-views]"
end
