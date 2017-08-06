module Audits
  class Filter
    include ActiveModel::Model
    attr_accessor :theme_id, :page, :organisations, :document_type, :audit_status, :primary_org_only, :after
  end
end
