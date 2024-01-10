Gem::Specification.new do |s|
  s.name        = "keycloak_managr"
  s.version     = "0.1.0"
  s.summary     = "Manage Keycloak accounts."
  s.description = "Manage Keycloak accounts, including locking of expired accounts"
  s.authors     = ["Trey Evans"]
  s.email       = "trey.evans@ideacrew.com"
  s.files       = Dir['lib/**/*.rb'] +  ["keycloak_managr.gemspec"]
  s.homepage    = "https://rubygems.org/gems/keycloak_managr"
  s.license     = "MIT"

  s.add_runtime_dependency "keycloak-admin", ">= 1.0.24"
  s.add_runtime_dependency "activesupport"
end
