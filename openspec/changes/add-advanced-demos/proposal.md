# Change: Add Advanced Demos

## Why
Power users need to see advanced Dart-ACDC features in action: request deduplication, stale-while-revalidate (SWR), request cancellation, and error handling with AcdcExceptions.

## What Changes
- **Request Deduplication Demo** – "Fire N Duplicate Requests" button showing single network call
- **Stale-While-Revalidate Demo** – Toggle to enable SWR, observe stale-then-fresh flow
- **Request Cancellation Demo** – Cancel button for in-flight requests
- **Error Handling Demo** – Buttons to trigger AcdcExceptions with formatted display

## Impact
- **Depends on**: `add-core-showcase-layout`, `add-feature-toggles`
- **Affected specs**: `showcase-advanced` (new capability)
- **Affected code**: New demo widgets, extended toggle panel
