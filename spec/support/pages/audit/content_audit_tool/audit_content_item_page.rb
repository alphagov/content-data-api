require 'site_prism/page'

class AuditContentItemPage < SitePrism::Page
  set_url '/content_items{/content_id}/audit{?query*}'

  element :error_message, '[data-test-id=audit-error-message]'
  element :success_message, '[data-test-id=audit-success-message]'

  element :content_item_description, '[data-test-id=content-item-description]'
  element :content_item_title, '[data-test-id=content-item-title]'
  element :questions_title, '[data-test-id=questions-title]'

  element :content_preview, '[data-test-id=content-preview]'

  section :audit_form, 'form' do
    element :attachments, '[data-test-id=change-attachments]'
    element :content_out_of_date, '[data-test-id=outdated]'
    element :content_should_be_removed, '[data-test-id=redundant]'
    element :content_similar, '[data-test-id=similar]'
    element :content_type, '[data-test-id=reformat]'
    element :notes, '[data-test-id=notes]'
    element :page_detail, '[data-test-id=change-body]'
    element :redirect_urls, '[data-test-id=redirect-urls]'
    element :save_and_continue, '[data-test-id=save-audit-form]'
    element :similar_urls, '[data-test-id=similar-urls]'
    element :summary, '[data-test-id=change-description]'
    element :title, '[data-test-id=change-title]'
  end

  section :metadata, '#metadata' do
    element :assigned_to, '[data-test-id=allocated]'
    element :audited, '[data-test-id=audited]'
    element :content_type, '[data-test-id=content-type]'
    element :guidance, '[data-test-id=guidance]'
    element :last_major_update, '[data-test-id=last-updated]'
    element :organisations, '[data-test-id=organisations]'
    element :policy_areas, '[data-test-id=policy-areas]'
    element :topics, '[data-test-id=topics]'
    element :unique_page_views, '[data-test-id=pageviews]'
    element :withdrawn, '[data-test-id=withdrawn]'
  end
end
