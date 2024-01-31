module KeycloakManagr
  # Extensions to the KeycloakAdmin gem to support our API calls.
  module KeycloakAdminExtensions
    # A client to query Event resources from Keycloak.
    class EventsClient < KeycloakAdmin::Client
      # Provide a pagination wrapper around events.
      class EventListPaginator

        # How many event records to pull per request.
        PAGINATION_LENGTH = 300

        # Create a new client.
        #
        # @param [Object] configuration a KeycloakAdmin client configuration,
        #                               comes from the parent EventClient
        # @param [String] lookup_url the URL to use to query events from
        #                            Keycloak, comes from the parent EventClient
        # @param [Object] extended_headers The headers needed for all requests,
        #                                  come from the parent EventClient
        def initialize(configuration, lookup_url, extended_headers)
          @lookup_url = lookup_url
          @extended_headers = extended_headers
          @configuration = configuration
        end

        # Iterate the results
        #
        # @yieldparam [Hash] event the event as a hash
        def each
          index = 0
          while true do
            response = RestClient::Resource.new(@lookup_url, @configuration.rest_client_options).get(add_header_offsets(index))
            events = JSON.parse(response)
            break if events.empty?
            events.each do |event|
              yield event
            end
            index += PAGINATION_LENGTH
          end
        end

        protected

        def add_header_offsets(index)
          eh = @extended_headers.symbolize_keys
          params = (eh[:params] != nil) ? eh[:params] : {}
          eh[:params] = params.merge(:first => index, :max => PAGINATION_LENGTH)
          eh
        end
      end

      def initialize(configuration, realm_client, realm_name)
        super(configuration)
        @realm_client = realm_client
        @realm_name = realm_name
      end

      # Search events with parameters.
      def search(query)
        extended_headers = headers.merge({params: query})
        EventListPaginator.new(@configuration, event_list_url, extended_headers)
      end

      protected

      def event_list_url
        "#{@realm_client.realm_admin_url}/events"
      end
    end

    # Monkey-patched extensions to KeycloakAdmin::UserClient
    module UserClientExtensions
      # Provide a pagination wrapper around users.
      class UserListPaginator

        include Enumerable

        # How many user records to pull per request.
        PAGINATION_LENGTH = 300

        # Create a new client.
        #
        # @param [Object] configuration a KeycloakAdmin client configuration,
        #                               comes from the parent UserClient
        # @param [String] lookup_url the URL to use to query users from
        #                            Keycloak, comes from the parent UserClient
        # @param [Object] extended_headers The headers needed for all requests,
        #                                  come from the parent UserClient
        # @param [Integer] total the total number of user records, queried as
        #                        count by the UserClient before the iterator is created.
        def initialize(configuration, lookup_url, extended_headers, total)
          @total = total
          @lookup_url = lookup_url
          @extended_headers = extended_headers
          @configuration = configuration
        end

        # Provide a total count of user records.
        def count
          @total
        end

        # Iterate the results.
        #
        # @yieldparam [KeycloakAdmin::UserResource] user The user resource.
        def each
          index = 0
          while index < @total do
            response = RestClient::Resource.new(@lookup_url, @configuration.rest_client_options).get(add_header_offsets(index))
            users = JSON.parse(response).map { |user_as_hash| ::KeycloakAdmin::UserRepresentation.from_hash(user_as_hash) }
            users.each do |user|
              yield user
            end
            index += PAGINATION_LENGTH
          end
        end

        protected

        def add_header_offsets( index)
          eh = @extended_headers.symbolize_keys
          params = (eh[:params] != nil) ? eh[:params] : {}
          eh[:params] = params.merge(:first => index, :max => PAGINATION_LENGTH, :briefRepresentation => false)
          eh
        end
      end

      # List users using arbitrary parameters, and paginate.
      def paginated_list(params = {})
        extended_headers = if params.empty?
                             headers
                           else
                             headers.merge({params: params})
                           end
        response = execute_http do
          RestClient::Resource.new(pagination_count_url, @configuration.rest_client_options).get(extended_headers)
        end
        total = response.to_s.to_i
        UserListPaginator.new(@configuration, users_url, extended_headers, total)
      end

      protected

      def pagination_count_url
        "#{@realm_client.realm_admin_url}/users/count"
      end
    end

    # Monkey-patched extensions to KeycloakAdmin::RealmClient
    module RealmClientExtensions
      # Access the Events sub-resource under a realm.
      def events
        ::KeycloakManagr::KeycloakAdminExtensions::EventsClient.new(@configuration, self, @realm_name)
      end
    end
  end

  ::KeycloakAdmin::UserClient.class_exec do
    include ::KeycloakManagr::KeycloakAdminExtensions::UserClientExtensions
  end

  ::KeycloakAdmin::RealmClient.class_exec do
    include ::KeycloakManagr::KeycloakAdminExtensions::RealmClientExtensions
  end
end