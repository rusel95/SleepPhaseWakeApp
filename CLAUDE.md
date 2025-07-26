# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SleepPhaseWakeApp is a watchOS-only application that wakes users during lighter sleep phases within a 30-minute window before their set alarm time. It uses accelerometer data to detect movement as a proxy for sleep phase identification.

## Common Development Commands

### Building
```bash
# Build for debug
xcodebuild -project SleepPhaseWakeApp.xcodeproj -scheme "SleepPhaseWakeApp WatchKit App" -configuration Debug build

# Build for release
xcodebuild -project SleepPhaseWakeApp.xcodeproj -scheme "SleepPhaseWakeApp WatchKit App" -configuration Release build
```

### Running
```bash
# Run on watchOS Simulator
xcodebuild -project SleepPhaseWakeApp.xcodeproj -scheme "SleepPhaseWakeApp WatchKit App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 8 - 45mm' build run
```

### Testing
No test infrastructure currently exists. When implementing tests, they should be added to a new test target in the Xcode project.

### Linting
No linting configuration currently exists. Consider adding SwiftLint for code consistency.

## High-Level Architecture

### Project Structure
- **watchOS-only app** built with Swift and SwiftUI (no iOS companion app yet)
- **MVVM architecture** with clear separation between Views, ViewModels, and Services
- **Swift Package Manager** for dependency management (currently only Sentry SDK)

### Key Components

1. **Sleep Session Service** (`SleepPhaseWakeApp WatchKit Extension/Services/SleepSessionService.swift`)
   - Singleton coordinator managing the entire sleep tracking lifecycle
   - Handles accelerometer data collection and movement detection
   - Manages background execution (limited to 30 minutes by watchOS)

2. **Screen Organization** (MVVM pattern in `Screens/` directory):
   - **NotStartedSession**: Initial state for setting wake-up time
   - **StartedSession**: Active monitoring with countdown timer
   - **FinishedSession**: Wake-up completion screen

3. **State Management**:
   - Uses `@AppStorage` for persistent state across app launches
   - Three main states: `noStarted`, `started`, `finished`
   - State transitions managed by ViewModels

4. **Movement Detection Algorithm**:
   - Located in `SleepSessionService.handleAccelerometerData()`
   - Triggers wake-up when total acceleration exceeds 1.2 threshold
   - Runs every second during the 30-minute wake window

### Technical Constraints

1. **30-minute background limit**: watchOS restricts background execution to 30 minutes maximum
2. **No HealthKit integration**: Currently relies solely on accelerometer data
3. **No test coverage**: Project lacks any testing infrastructure
4. **Simple threshold-based detection**: Wake-up triggered by first movement above threshold

### Dependencies

- **Sentry SDK (8.47.0)**: Crash reporting and performance monitoring
- **Firebase**: Configuration present but SDK not integrated

### Future Enhancements (from README)

1. Beta testing and user feedback collection
2. Sleep phase algorithm improvements using:
   - Movement frequency patterns
   - Heart rate data
   - Apple's HKCategorySleepAnalysis
3. Companion iOS app for detailed sleep analytics
4. UI/UX redesign