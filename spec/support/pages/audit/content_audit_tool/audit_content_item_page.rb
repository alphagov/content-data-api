require 'site_prism/page'

class AuditContentItemPage < SitePrism::Page
  set_url '/content_items{/content_id}/audit{?query*}'

  element :error_message, '.alert-danger'
  element :success_message, '.alert-success'

  element :content_item_description, 'p.description'
  element :content_item_title, 'h2'
  element :questions_title, 'h4'

  section :audit_form, 'form' do
    element :attachments, '.change-attachments'
    element :content_out_of_date, '.outdated'
    element :content_should_be_removed, '.redundant'
    element :content_similar, '.similar'
    element :content_type, '.reformat'
    element :notes, '.notes textarea'
    element :page_detail, '.change-body'
    element :redirect_urls, '#audits_audit_redirect_urls'
    element :save_and_continue, 'input[type=submit]'
    element :similar_urls, '#audits_audit_similar_urls'
    element :summary, '.change-description'
    element :title, '.change-title'
  end

  section :metadata, '#metadata' do
    element :assigned_to, '#allocated'
    element :audited, '#audited'
    element :content_type, '#content-type'
    element :guidance, '#guidance'
    element :last_major_update, '#last-updated'
    element :organisations, '#organisations'
    element :policy_areas, '#policy-areas'
    element :topics, '#topics'
    element :unique_page_views, '#pageviews'
    element :withdrawn, '#withdrawn'
  end
end
