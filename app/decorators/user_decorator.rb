class UserDecorator < Draper::Decorator
  delegate_all

  def department
    slug = user.organisation_slug
    slug.titleize if slug
  end
end
