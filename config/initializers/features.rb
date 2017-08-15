require 'feature'

repository = Feature::Repository::YamlRepository.new(
  Rails.root.join('config/features.yml'),
  Rails.env,
)

Feature.set_repository(repository)
