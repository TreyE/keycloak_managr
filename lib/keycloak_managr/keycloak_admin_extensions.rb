# Extensions to the KeycloakAdmin gem to support our API calls.
#
# Instead of monkey-patching, most of this should be moved into injection via
# modules.
module KeycloakAdmin
  # A client to query Event resources from Keycloak.
  class EventsClient < Client
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

  # Monkey-patched extensions to KeycloakAdmin::RealmClient
  class RealmClient < Client
    # Access the Events sub-resource under a realm.
    def events
      EventsClient.new(@configuration, self, @realm_name)
    end
  end

  # Monkey-patched extensions to KeycloakAdmin::UserClient
  class UserClient < Client
    # List users using arbitrary parameters.
    #
    # We use it to pass in a parameter which prevents limiting of the returned
    # amount of user records.
    def list_with_params(params)
      response = execute_http do
      RestClient::Resource.new(users_url, @configuration.rest_client_options).get(headers.merge({params: params}))
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end
  end
end