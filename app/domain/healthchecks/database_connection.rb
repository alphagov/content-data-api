module Healthchecks
  class DatabaseConnection
    def name
      :database_status
    end

    def status
      Dimensions::Date.first ? :ok : :critical
    end

    def message
      "Can't connect to Database"
    end

    def enabled?
      true
    end
  end
end
