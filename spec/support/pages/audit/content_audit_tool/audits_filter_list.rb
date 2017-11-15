require "site_prism/page"

class AuditsFilterList < SitePrism::Page
  element :list, "table[data-test-id=filter-list] tbody"
  sections :listings, AuditListingSection, "table[data-test-id=filter-list] tbody tr"
end
