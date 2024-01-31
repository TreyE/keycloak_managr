require_relative "lib/keycloak_managr"

# Configuration.  Check out the 'Login' section of 
# 'https://github.com/looorent/keycloak-admin-ruby' for information on
# configuring a client for the master realm.
config = {
  :server_url          => "URL INCLUDING /auth GOES HERE",
  :server_domain       => "master",
  :client_id           => "account-expiry",
  :client_realm_name   => "master",
  :username            => "account-expiry",
  :password            => "PASSWORD GOES HERE",
  :client_secret       => "CLIENT SECRET GOES HERE"
}

KeycloakManagr.execute_configuration!(config)

dont_lock_admin = Proc.new { |realm_name, user| user.username != "admin" }

locker = KeycloakManagr::ExpiredLogins::AccountLocker.new(
  "master",
  60,
  dont_lock_admin
)
locker.run!(true)