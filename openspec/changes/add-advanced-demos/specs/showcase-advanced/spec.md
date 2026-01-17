## ADDED Requirements

### Requirement: Request Deduplication Demo
The app SHALL demonstrate that multiple identical simultaneous requests result in only one network call, with all callers receiving the same response.

#### Scenario: User fires duplicate requests
- **WHEN** user taps "Fire 5 Duplicate Requests" button
- **THEN** the log viewer shows only 1 network call was made and 5 responses were delivered

### Requirement: Stale-While-Revalidate Demo
The app SHALL demonstrate the SWR pattern using the `streamRequest` extension, showing cached data immediately followed by fresh data from the network.

#### Scenario: User triggers SWR request
- **WHEN** user sends a request with SWR toggle enabled
- **THEN** the stale cached response is displayed first, then automatically updated with the fresh network response

#### Scenario: SWR logs show dual responses
- **WHEN** SWR request completes
- **THEN** the log viewer shows both the cache hit and the subsequent network fetch

### Requirement: Request Cancellation
The app SHALL provide a "Cancel" button to abort in-flight requests, demonstrating CancelToken usage.

#### Scenario: User cancels pending request
- **WHEN** user taps "Cancel" during a slow request
- **THEN** the request is aborted and the log viewer shows a cancellation event

### Requirement: Error Handling Demo
The app SHALL demonstrate Dart-ACDC exception types by providing buttons to intentionally trigger error scenarios and displaying exception details.

#### Scenario: User triggers auth error
- **WHEN** user taps "Trigger Auth Error"
- **THEN** an AcdcAuthException is thrown and its details are displayed

#### Scenario: User triggers cache error
- **WHEN** user taps "Trigger Cache Error"
- **THEN** an AcdcCacheException is thrown and its details are displayed
