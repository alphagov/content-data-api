class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, type: Array, coder: JSON

  def organisation
    @organisation ||= item.find_by(content_id: organisation_content_id)
  end
end
