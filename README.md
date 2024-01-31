# Keycloak Managr

A simple gem to perform administration tasks via the Keycloak Rest API.

To get started quickly, check the `examples` directory.

## Advantages

1. Uses existing SSO provider for both Enroll and Carrier Portal to perform account management
2. Allows client administrators to manage unlocking of own accounts via Keycloak Administrative interface with no additional development for Carrier Portal or Enroll, and no IdeaCrew devops involvement
3. Also provides locking functionality for Keycloak administrative users in the master domain