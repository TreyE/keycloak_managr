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
only_lock_ideacrew_carrier_portal = Proc.new do |realm_name, user|
  (user.username =~ /@ideacrew.com\Z/i) &&
    (user.attributes && user.attributes.has_key?("transaction_management_carriers"))
end

locker1 = KeycloakManagr::ExpiredLogins::AccountLocker.new(
  "master",
  60,
  dont_lock_admin
)
locker1.run!(true)

locker2 = KeycloakManagr::ExpiredLogins::AccountLocker.new(
  "preprod",
  60,
  only_lock_ideacrew_carrier_portal,
  KeycloakManagr::ExpiredLogins::AccountLockerCsvReport.new("before_locking.csv"),
  KeycloakManagr::ExpiredLogins::AccountLockerCsvReport.new("after_locking.csv")
)
locker2.run!
