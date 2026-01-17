# Change: Add Core Showcase Layout

## Why
The example app needs a foundational 3-panel layout with a request builder, response display, and real-time log viewer. This establishes the core interactive framework for demonstrating Dart-ACDC features.

## What Changes
- **3-Panel Layout** – Request Builder (left), Response Panel (center), Log Viewer (right)
- **Request Builder** – HTTP verb dropdown, endpoint URL field, headers input, Send button
- **Response Panel** – Raw JSON display with syntax formatting, error response handling
- **Log Viewer** – Embedded Talker with log level filter and clear button
- **Material 3 Theme** – Modern, polished aesthetics

## Impact
- **Affected specs**: `showcase-core` (new capability)
- **Affected code**: `lib/main.dart`, new widget files
