## ADDED Requirements

### Requirement: Feature Toggles
The app SHALL provide toggles to enable/disable Dart-ACDC features (auth, caching, offline detection), allowing users to observe their behavior in the logs.

#### Scenario: User enables caching
- **WHEN** user toggles caching ON
- **THEN** the AcdcClientBuilder is reconfigured with caching enabled, visible in the code snippet panel

#### Scenario: User disables authentication
- **WHEN** user toggles authentication OFF
- **THEN** requests are sent without Authorization headers (visible in logs)

### Requirement: Real-Time Log Viewer Enhancement
The log viewer SHALL display all Dart-ACDC interceptor activity including cache operations and authentication events.

#### Scenario: User observes cache hit
- **WHEN** a cached response is returned
- **THEN** the log viewer shows a "Cache HIT" entry with details

#### Scenario: User observes auth token injection
- **WHEN** an authenticated request is sent
- **THEN** the log viewer shows the Authorization header being added

### Requirement: Offline Detection Demo
The app SHALL demonstrate the OfflineInterceptor behavior, allowing users to simulate offline mode and observe how requests are handled.

#### Scenario: User simulates offline mode
- **WHEN** user toggles "Simulate Offline" ON and sends a request
- **THEN** the request fails immediately with an offline error (fail-fast behavior)

#### Scenario: Offline status is visible
- **WHEN** offline mode is simulated
- **THEN** a visible "Offline" indicator is displayed in the UI

### Requirement: Code Snippet Display
The app SHALL display the live `AcdcClientBuilder` configuration code reflecting the current feature toggle states.

#### Scenario: User views configuration code
- **WHEN** user has caching and auth enabled
- **THEN** the code snippet shows `.withCache(...)` and `.withTokenProvider(...)` calls

#### Scenario: Code updates on toggle change
- **WHEN** user toggles a feature ON or OFF
- **THEN** the code snippet updates immediately to reflect the change
