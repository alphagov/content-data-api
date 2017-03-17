require 'rails_helper'

RSpec.describe "API::Groups", type: :request do
  describe "GET /groups/{id}" do
    it "returns JSON with the group " do
      group = create :group, name: "a-name", slug: "the-slug"
      get group_path(group), format: :json

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to include(
        name: "a-name",
        slug: "the-slug"
      )
    end
  end
end
