## ADDED Requirements

### Requirement: The application SHALL SSL Certificate Handling
Git operations over HTTPS SHALL support custom CA certificates by reading system certificates cross-platform and configuring them in the Rust git2 backend.

#### Scenario: Reading system CA certificates
Given the application is running on any supported platform
When sync is initialized
Then system CA certificates are read and passed to Rust for git2 configuration

#### Scenario: Handling certificate read failure
Given certificate reading fails on a platform
When sync operations are attempted
Then operations fall back to default SSL behavior without interruption

#### Scenario: Successful SSL validation with custom CA
Given a remote repository requiring custom CA validation
When Git operations are performed
Then certificates are validated successfully using provided CA certificates