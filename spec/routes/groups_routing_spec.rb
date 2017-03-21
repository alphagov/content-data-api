require "rails_helper"

RSpec.describe GroupsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/groups/the-slug").to route_to("groups#show", slug: "the-slug")
    end
    it "routes to #create" do
      expect(post: "/groups").to route_to("groups#create")
    end
  end
end
