require 'guard/compat/plugin'

module Guard
  class Lint < Plugin
    CMD = "bundle exec govuk-lint-ruby -a".freeze

    def run_all
      system(CMD)
    end

    def run_on_modifications(files)
      system("#{CMD} #{files.join(' ')}")
    end
  end
end
