require_relative "lib/keycloak_managr"

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
only_lock_trey = Proc.new { |realm_name, user| user.username =~ /trey.evans@ideacrew.com\Z/i }

locker1 = KeycloakManagr::ExpiredLogins::AccountLocker.new(
  "master",
  30,
  dont_lock_admin
)
locker1.run!(true)

locker2 = KeycloakManagr::ExpiredLogins::AccountLocker.new(
  "preprod",
  30,
  only_lock_trey,
  KeycloakManagr::ExpiredLogins::AccountLockerCsvReport.new("before_locking.csv"),
  KeycloakManagr::ExpiredLogins::AccountLockerCsvReport.new("after_locking.csv")
)
locker2.run!
