class Heroku
  def self.create_users(organisation_id)
    organisation = Content::Item.find(organisation_id)

    User.create!(
      name: 'AT user',
      email: 'uat@gds.com',
      uid: SecureRandom.uuid,
      organisation_slug: organisation.title.parameterize.underscore,
      organisation_content_id: organisation.content_id,
    )
  end
end
