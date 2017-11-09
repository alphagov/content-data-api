require "site_prism/page"

class AuditsFilterList < SitePrism::Page
  sections :filter_listings, AuditListingSection, "[data-test-id=filter-list] tbody tr"
end
