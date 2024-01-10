module KeycloakAdmin
  class EventsClient < Client
    def initialize(configuration, realm_client, realm_name)
      super(configuration)
      @realm_client = realm_client
      @realm_name = realm_name
    end

    def event_list_url
      @realm_client.server_url + "/admin/realms/#{@realm_name}/events"
    end

    def list
      response = execute_http do
        RestClient::Resource.new(event_list_url, @configuration.rest_client_options).get(headers.merge({params: {max: -1}}))
      end
      JSON.parse(response)
    end

    def search(query)
      response = execute_http do
        RestClient::Resource.new(event_list_url, @configuration.rest_client_options).get(headers.merge({params: query.merge({max: -1})}))
      end
      JSON.parse(response)
    end
  end

  class RealmClient < Client
    def events
      EventsClient.new(@configuration, self, @realm_name)
    end
  end

  class UserClient < Client
    def list_with_params(params)
      response = execute_http do
      RestClient::Resource.new(users_url, @configuration.rest_client_options).get(headers.merge({params: params}))
      end
      JSON.parse(response).map { |user_as_hash| UserRepresentation.from_hash(user_as_hash) }
    end
  end
end