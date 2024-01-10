module KeycloakManagr
  class LastLoginReport
    attr_reader :records

    def initialize(realm_name)
      @realm_name = realm_name
      @records = Array.new
      @built = false
    end

    def display(stream = STDOUT)
      build!
      stream.puts "Realm name: #{@realm_name}"
      @records.each do |rec|
        stream.puts "#{rec[0].username} - #{rec[1]}"
      end
    end

    def build!
      return if @built
      login_events = KeycloakAdmin.realm(@realm_name).events.search("type" => "LOGIN")
      users = KeycloakAdmin.realm(@realm_name).users.list_with_params({"max" => -1})
    
      login_events_hash = Hash.new { |h, k| h[k] = Array.new }
      login_events.each do |le|
        user_id = le["userId"]
        login_events_hash[user_id] = login_events_hash[user_id] + [le['time']]
      end
    
      users.each do |user|
        user_login_times = login_events_hash[user.id]
        last_login_time = user_login_times.empty? ? nil : Time.at(user_login_times.max/1000)
        @records << [user, last_login_time]
      end
      @built = true
    end
  end
end