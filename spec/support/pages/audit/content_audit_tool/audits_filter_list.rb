require "site_prism/page"

class AuditsFilterList < SitePrism::Page
  sections :filter_listings, AuditListingSection, "[data-test=filter-list] tbody tr"
end
