module KeycloakManagr
  # Extensions to the KeycloakAdmin gem to support our API calls.
  module KeycloakAdminExtensions
    # A client to query Event resources from Keycloak.
    class EventsClient < KeycloakAdmin::Client
      def initialize(configuration, realm_client, realm_name)
        super(configuration)
        @realm_client = realm_client
        @realm_name = realm_name
      end

      # List all events
      def list
        response = execute_http do
          RestClient::Resource.new(event_list_url, @configuration.rest_client_options).get(headers.merge({params: {max: -1}}))
        end
        JSON.parse(response)
      end

      # Search events with parameters.
      def search(query)
        response = execute_http do
          RestClient::Resource.new(event_list_url, @configuration.rest_client_options).get(headers.merge({params: query.merge({max: -1})}))
        end
        JSON.parse(response)
      end

      protected

      def event_list_url
        @realm_client.server_url + "/admin/realms/#{@realm_name}/events"
      end
    end

    # Monkey-patched extensions to KeycloakAdmin::UserClient
    module UserClientExtensions
      # List users using arbitrary parameters.
      #
      # We use it to pass in a parameter which prevents limiting of the returned
      # amount of user records.
      def list_with_params(params)
        response = execute_http do
        RestClient::Resource.new(users_url, @configuration.rest_client_options).get(headers.merge({params: params}))
        end
        JSON.parse(response).map { |user_as_hash| ::KeycloakAdmin::UserRepresentation.from_hash(user_as_hash) }
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