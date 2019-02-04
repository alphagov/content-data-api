module Healthchecks
  class DatabaseConnection
    def name
      :database_status
    end

    def status
      Dimensions::Date.first ? OK : CRITICAL
    end
  end
end
