require 'csv'

module KeycloakManagr
  module ExpiredLogins
    # Reports on the actions of the AccountLocker to a csv.
    class AccountLockerCsvReport
      # New report.
      #
      # @param [String] file_path the path for the report CSV
      def initialize(file_path)
        @file_path = file_path
      end

      # Start and end a report.
      def with_report(realm_name)
        CSV.open(@file_path, "wb") do |csv|
          csv << ["Account Username", "Last Login", "Enabled", "Action"]
          @csv = csv
          yield self
          @csv = nil
        end
      end

      # Add a record to the report.
      def add_record(user_account, last_login, check_result)
        @csv << [user_account.username, last_login, user_account.enabled, check_result]
      end
    end
  end
end