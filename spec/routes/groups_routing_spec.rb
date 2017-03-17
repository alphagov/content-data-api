require "rails_helper"

RSpec.describe GroupsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/groups/1").to route_to("groups#show", id: "1")
    end
  end
end
