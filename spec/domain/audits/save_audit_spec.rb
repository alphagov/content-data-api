module Audits
  RSpec.describe SaveAudit do
    let!(:user) { create :user }
    let!(:content_item) { create :content_item, title: "A title" }
    let!(:attributes) { attributes_for :audit }

    it "creates a new audit" do
      result = SaveAudit.call(
        attributes: attributes,
        content_id: content_item.content_id,
        user_uid: user.uid
      )

      expect(result.audit).to have_attributes(change_title: false)
      expect(result.content_item.title).to eq("A title")
      expect(result.success).to eq(true)
    end

    it "clears the redirect_urls field when redundant is set to no" do
      redundant_content_item = create(:content_item)
      audit_with_redirect_urls = create(
        :failing_audit,
        content_item: redundant_content_item,
        redirect_urls: "http://www.example.com"
      )

      expect(Audits::Audit.find(audit_with_redirect_urls.id).redirect_urls).to eq("http://www.example.com")

      attributes[:redundant] = false
      attributes[:redirect_urls] = "http://www.example.com"

      result = SaveAudit.call(
        attributes: attributes,
        content_id: redundant_content_item.content_id,
        user_uid: user.uid
      )

      expect(result.audit).to eq(audit_with_redirect_urls)
      expect(result.audit.redirect_urls).to be_empty
      expect(Audits::Audit.find(audit_with_redirect_urls.id).redirect_urls).to be_empty
    end

    it "clears the similar content URLs when not similar to others" do
      similar_content_item = create(:content_item)
      audit_with_similar_content = create(
        :failing_audit,
        content_item: similar_content_item,
        similar_urls: "http://www.similar.com"
      )

      expect(Audits::Audit.find(audit_with_similar_content.id).similar_urls).to eq("http://www.similar.com")

      attributes[:similar] = false
      attributes[:similar_urls] = "http://www.similar.com"

      result = SaveAudit.call(
        attributes: attributes,
        content_id: similar_content_item.content_id,
        user_uid: user.uid
      )

      expect(result.audit).to eq(audit_with_similar_content)
      expect(result.audit.similar_urls).to be_empty
    end
  end
end
