# Project Context

## Purpose
This project serves as a comprehensive example for the `dart_acdc` library, demonstrating how to build a production-ready HTTP client. It specifically targets the **Google Tasks API** and public APIs to showcase "Zero-Config" features like authentication, smart caching (both user-isolated and standard HTTP caching), and observability with real-time logging.

## Tech Stack
- **Languages**: Dart 3.x, Flutter
- **Core Libraries**:
  - `dart_acdc` (Authentication & Client Builder)
  - `dio` (HTTP Client)
  - `flutter_web_auth_2` (OAuth2 Implicit Flow)
  - `built_collection` (Immutable Collections)
- **Tools**:
  - `openapi` (Client Generation)
  - `flutter_lints` (Linting)

## Project Conventions

### Code Style
- Follows standard Flutter and Dart style guides.
- Enforced by `flutter_lints` version `^6.0.0`.

### Architecture Patterns
- **Zero-Config Client**: Leverages `dart_acdc` to minimize boilerplate for Dio client setup.
- **API Client Generation**: Uses OpenAPI generator for type-safe API interactions (located in `lib/api_client`).
- **Auth Utils**: Separated authentication logic (e.g., `google_tasks_auth_helper.dart`).

### Testing Strategy
- Includes `flutter_test` for unit and widget testing.
- Manual verification via the example app UI (logs, cache hits, authentication flows).

### Git Workflow
- Standard feature branching.
- Dependency on local `../Dart-ACDC` requires coordination with the main library overrides.

## Domain Context
- **Google Tasks API**: The primary authenticated API being demonstrated.
- **OAuth2 Implicit Flow**: The specific authentication mechanism used for the demo.
- **Deep Linking**: Required for mobile authentication redirects (`dartacdc://callback`).

## Important Constraints
- **Platform Support**: The app must work on **iOS** and **Android** in addition to Web.
- **Google Cloud Requirement**: A Google Cloud Project with Google Tasks API enabled is mandatory for full functionality.
- **Web Port**: Configured to run on port 3000 for redirect URI consistency.
- **Local Dependency**: Depends on the parent `Dart-ACDC` package via path.

## External Dependencies
- **Google Identity Platform**: For OAuth2 authentication.
- **httpbin.org**: Used for testing public API caching behaviors.
