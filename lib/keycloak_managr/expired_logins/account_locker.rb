module KeycloakManagr
  module ExpiredLogins
    class AccountLocker
      def initialize(
        realm_name,
        expiration_days = 90,
        lock_selection_criteria = Proc.new { |realm_name, user| false },
        before_report = AccountLockerConsoleReport.new,
        after_report = AccountLockerConsoleReport.new
      )
        @realm_name = realm_name
        @report = LastLoginReport.new(@realm_name)
        @expiration_days = expiration_days
        @lock_selection_criteria = lock_selection_criteria
        @locked_accounts = []
        @before_report = before_report
        @after_report = after_report
      end

      def produce_before_action_report(stream = STDOUT)
        @report.build!
        @before_report.with_report(@realm_name) do |report|
          @report.records.each do |rec|
            report.add_record(rec[0], rec[1], time_check(rec[0], rec[1]))
          end
        end
      end

      # The main entry point.
      def run!(dryrun = false)
        produce_before_action_report
        lock_accounts! unless dryrun
        produce_after_action_report
      end

      def select_accounts_to_lock!
        @report.build!
        @accounts_to_lock = []
        @report.records.each do |rec|
          if (time_check(rec[0], rec[1]) == "LOCK") && rec[0].enabled
            @accounts_to_lock << rec
          end
        end
      end

      def lock_accounts!
        select_accounts_to_lock!
        @accounts_to_lock.each do |rec|
          lock_account!(rec[0])
        end
      end

      def produce_after_action_report(stream = STDOUT)
        @after_action_report = LastLoginReport.new(@realm_name)
        @after_action_report.build!
        @after_report.with_report(@realm_name) do |report|
          @after_action_report.records.each do |rec|
            report.add_record(rec[0], rec[1], time_check(rec[0], rec[1]))
          end
        end
      end

      def lock_account!(user)
        realm_client.users.update(
          user.id,
          { enabled: false }
        )
      end

      def realm_client
        return @realm_client if @realm_client
        KeycloakAdmin.realm(@realm_name)
      end

      def time_check(user, time)
        would_lock = if time
                      ((Time.now - time) > @expiration_days.days) ? "LOCK" : "HAS RECENT LOGIN"
                    else
                      "UNKNOWN"
                    end
        selected = @lock_selection_criteria.call(@realm_name, user)
        return "#{would_lock} - Excluded by Criteria" unless selected
        would_lock
      end
    end
  end
end