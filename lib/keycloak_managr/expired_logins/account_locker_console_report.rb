module KeycloakManagr
  module ExpiredLogins
    # Reports on the actions of the AccountLocker to a stream.
    class AccountLockerConsoleReport
      # Create a new report.
      #
      # @param [#puts] stream Anything that acts like a stream.
      def initialize(stream = STDOUT)
        @stream = stream
      end

      # Start and end a report.
      def with_report(realm_name)
        @stream.puts "Realm Name: #{realm_name}"
        yield self
      end

      # Add a record to the report.
      def add_record(user_account, last_login, check_result)
        @stream.puts "#{user_account.username} - Enabled: #{user_account.enabled} #{last_login} : #{check_result}"
      end
    end
  end
end