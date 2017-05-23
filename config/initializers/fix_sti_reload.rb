# This fixes a problem with reloading STI models in development mode.
# See: https://github.com/rails/rails/issues/8699
def fix_sti_reload_in_development(file)
  return unless Rails.env.development?
  Dir[file.gsub(".rb", "/*.rb")].each { |f| require_dependency f }
end
