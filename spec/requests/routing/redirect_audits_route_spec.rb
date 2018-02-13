RSpec.describe "/audits", type: :request do
  describe "audits" do
    it "redirects to the Content Audit Tool" do
      get "/audits"
      expect(response).to redirect_to(Plek.find("content-audit-tool"))
    end
  end
end
