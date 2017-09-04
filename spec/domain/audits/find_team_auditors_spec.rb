module Audits
  RSpec.describe FindTeamAuditors do
    subject { described_class }

    let(:user_uid) { "uid1" }
    let!(:user) { create :user, :with_allocated_content, uid: user_uid, organisation_slug: "organisation_slug" }

    it "returns only auditors belonging to my organisation" do
      create :user, organisation_slug: :other_org_slug

      expect(subject.call(user_uid: user_uid)).to match_array(user)
    end

    it "returns only users with content allocated" do
      create :user, organisation_slug: "organisation_slug"

      users = subject.call(user_uid: user_uid)
      expect(users).to match_array([user])
    end
  end
end
