require 'csv'

module KeycloakManagr
  module ExpiredLogins
    class AccountLockerCsvReport
      def initialize(file_path)
        @file_path = file_path
      end

      def with_report(realm_name)
        CSV.open(@file_path, "wb") do |csv|
          csv << ["Account Username", "Last Login", "Enabled", "Action"]
          @csv = csv
          yield self
          @csv = nil
        end
      end

      def add_record(user_account, last_login, check_result)
        @csv << [user_account.username, last_login, user_account.enabled, check_result]
      end
    end
  end
end