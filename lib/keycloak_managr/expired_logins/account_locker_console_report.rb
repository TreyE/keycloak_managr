module KeycloakManagr
  module ExpiredLogins
    class AccountLockerConsoleReport
      def initialize(stream = STDOUT)
        @stream = stream
      end

      def with_report(realm_name)
        @stream.puts "Realm Name: #{realm_name}"
        yield self
      end

      def add_record(user_account, last_login, check_result)
        @stream.puts "#{user_account.username} - Enabled: #{user_account.enabled} #{last_login} : #{check_result}"
      end
    end
  end
end