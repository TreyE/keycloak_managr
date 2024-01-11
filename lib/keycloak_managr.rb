require 'active_support'
require 'active_support/core_ext/numeric'
require "keycloak-admin"

require_relative 'keycloak_managr/keycloak_admin_extensions'
require_relative 'keycloak_managr/last_login_report'
require_relative 'keycloak_managr/expired_logins'

# Various tools to manage keycloak via the REST API.
module KeycloakManagr
  # Run the initialization code to setup the KeycloakAdmin client.
  def execute_configuration!(configuration_options = {})
    config_options = configuration_options.symbolize_keys
    KeycloakAdmin.configure do |config|
      config.use_service_account = false
      config.server_url          = config_options[:server_url] || ENV['KEYCLOAK_SERVER_URL']
      config.server_domain       = config_options[:server_domain] || ENV['KEYCLOAK_SERVER_DOMAIN']
      config.client_id           = config_options[:client_id] || ENV['KEYCLOAK_CLIENT_ID']
      config.client_realm_name   = config_options[:client_realm_name] || ENV['KEYCLOAK_CLIENT_REALM_NAME']
      config.username            = config_options[:username] || ENV['KEYCLOAK_USERNAME']
      config.password            = config_options[:password] || ENV['KEYCLOAK_PASSWORD']
      config.client_secret       = config_options[:client_secret] || ENV['KEYCLOAK_CLIENT_SECRET']
      config.rest_client_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
    end
  end
  module_function :execute_configuration!
end
