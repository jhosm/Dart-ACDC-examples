## ADDED Requirements

### Requirement: Request Builder
The app SHALL provide a simple request builder allowing users to specify HTTP verb (GET/POST/PUT/DELETE), endpoint URL, and optional headers (key-value pairs).

#### Scenario: User sends a GET request
- **WHEN** user enters verb "GET", endpoint "https://httpbin.org/get", and taps "Send"
- **THEN** the request is executed and the raw JSON response is displayed in the response panel

#### Scenario: User adds custom headers
- **WHEN** user adds header "X-Custom: value" and sends a request
- **THEN** the header is included in the request (visible in logs)

#### Scenario: Request fails with network error
- **WHEN** user sends a request and a network error occurs
- **THEN** the error is displayed in the response panel and logged

### Requirement: Raw JSON Response Display
The app SHALL display API responses as raw, formatted JSON in a dedicated response panel, including both successful and error responses.

#### Scenario: Successful response is displayed
- **WHEN** a request completes with 2xx status
- **THEN** the raw JSON response body is displayed in a scrollable, formatted view

#### Scenario: Error response is displayed
- **WHEN** a request completes with 4xx/5xx status
- **THEN** the error response body is displayed with error status highlighted

### Requirement: Real-Time Log Viewer
The app SHALL provide a prominent, real-time log viewer that displays all HTTP activity including request/response details and timing.

#### Scenario: User observes request logs
- **WHEN** a request is sent
- **THEN** the log viewer shows request method, URL, headers, and response details

#### Scenario: User filters log level
- **WHEN** user selects "Error" log level filter
- **THEN** only error-level logs are displayed

#### Scenario: User clears logs
- **WHEN** user taps "Clear Logs"
- **THEN** all log entries are removed from the viewer

### Requirement: Modern UI Design
The app SHALL use Material 3 design principles with a clean, modern aesthetic featuring a 3-panel layout.

#### Scenario: App renders on web
- **WHEN** user opens the app in Chrome
- **THEN** the UI displays with three distinct panels and Material 3 styling

#### Scenario: Responsive layout
- **WHEN** user resizes the browser window
- **THEN** the layout adapts appropriately for the viewport size
