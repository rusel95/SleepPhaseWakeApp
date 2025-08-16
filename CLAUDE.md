# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SleepPhaseWakeApp is a watchOS-only application that wakes users during lighter sleep phases within a 30-minute window before their set alarm time. It uses accelerometer data to detect movement as a proxy for sleep phase identification.

## Architecture Principles

### MUST Follow:
1. **SOLID Principles** - Every new feature/change must adhere to SOLID
2. **DRY (Don't Repeat Yourself)** - Extract common logic into reusable components
3. **Protocol-Oriented Programming** - Use protocols for abstraction, not inheritance
4. **Singleton Pattern** - Use for shared services (no DependencyContainer)
5. **MVVM Architecture** - Clear separation between Views and ViewModels

### Code Standards:
- All new files must include proper author header (Ruslan Popesku)
- Keep protocols and their single implementation in the same file
- Create unit tests for business logic
- Ensure UI works on all watchOS screen sizes (especially SE 40mm/44mm)
- No ViewModelBase or unnecessary abstractions

## Architecture Patterns

When implementing new features, consider these patterns:

### Primary Pattern: MVVM (Model-View-ViewModel)
- **Already in use** - Separates UI from business logic
- Works seamlessly with SwiftUI's reactive nature
- ViewModels handle state and business logic
- Views are purely declarative

### Alternative Patterns to Consider:
- **MVP (Model-View-Presenter)**: When you need more control over view logic
- **Clean Architecture**: For complex features with multiple data sources
- **Coordinator Pattern**: For managing complex navigation flows
- **Unidirectional Data Flow**: For features with complex state management

### Patterns to Avoid:
- **MVC**: Can lead to massive view controllers
- **VIPER**: Overcomplicated for watchOS apps

## Design Patterns

### Currently Used:
- **Singleton**: For shared services (AppStateManager, AccelerometerService)
- **Observer**: Through Combine and @Published properties
- **Protocol-Oriented Programming**: Primary abstraction mechanism
- **Strategy**: MovementDetector implements different detection algorithms

### Recommended Patterns:
- **Factory**: When creating complex objects with multiple configurations
- **Builder**: For constructing multi-step objects
- **Repository**: To abstract data access (future enhancement)
- **Facade**: To simplify complex subsystem interactions
- **Dependency Injection**: Pass dependencies, don't create them

### Use Sparingly:
- **Singleton**: Only for truly shared state/services

## iOS-Specific Patterns

### SwiftUI Patterns:
- **@StateObject/@ObservedObject**: For ViewModel bindings
- **@EnvironmentObject**: For app-wide shared state
- **ViewModifier**: For reusable view modifications
- **PreferenceKey**: For child-to-parent communication

### Combine Patterns:
- **Publishers/Subscribers**: For reactive data streams
- **Operators**: For transforming data flows
- **Cancellables**: Proper memory management

## Best Practices

### Core Principles:
- **SOLID Principles** (mandatory)
- **DRY (Don't Repeat Yourself)** - Extract reusable logic
- **KISS (Keep It Simple, Stupid)** - Avoid overengineering
- **YAGNI (You Aren't Gonna Need It)** - Don't add unused features
- **Composition over Inheritance** - Use protocols and composition

### Swift-Specific:
- **Protocol-Oriented Programming** over class inheritance
- **Value Types** (structs) over reference types when possible
- **Optionals** instead of force unwrapping
- **Guard statements** for early returns
- **Extensions** to organize code logically

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
```bash
# Run unit tests
xcodebuild test -project SleepPhaseWakeApp.xcodeproj -scheme "SleepPhaseWakeAppTests" -destination 'platform=watchOS Simulator,name=Apple Watch SE (44mm) (2nd generation)'
```

### Linting
No linting configuration currently exists. Consider adding SwiftLint for code consistency.

## High-Level Architecture

### Project Structure
- **watchOS-only app** built with Swift and SwiftUI (no iOS companion app yet)
- **MVVM architecture** with clear separation between Views, ViewModels, and Services
- **Protocol-Oriented Programming** with SOLID principles throughout
- **Swift Package Manager** for dependency management (currently only Sentry SDK)

### Key Components

1. **Services** (Following Single Responsibility Principle):
   - **AppStateManager**: Singleton managing app state persistence
   - **AccelerometerService**: Hardware sensor interface (implements SensorDataProvider)
   - **MovementDetector**: Analyzes sensor data for wake-up decisions
   - **UserNotificationService**: Handles all notification logic
   - **SleepSessionCoordinatorService**: Orchestrates the sleep tracking lifecycle

2. **Screen Organization** (MVVM pattern in `Screens/` directory):
   - **NotStartedSession**: Initial state for setting wake-up time
   - **StartedSession**: Active monitoring with countdown timer
   - **FinishedSession**: Wake-up completion screen

3. **State Management**:
   - Centralized in `AppStateManager` singleton
   - Uses `@AppStorage` for persistent state across app launches
   - Three main states: `notStarted`, `started`, `finished`
   - State transitions managed by ViewModels through protocol abstraction

4. **Movement Detection Algorithm**:
   - Isolated in `MovementDetector` class (Single Responsibility)
   - Triggers wake-up when total acceleration exceeds 1.2 threshold
   - Runs every second during the 30-minute wake window
   - Implements `AccelerometerDataHandler` protocol for testability

### Technical Constraints

1. **30-minute background limit**: watchOS restricts background execution to 30 minutes maximum
2. **No HealthKit integration**: Currently relies solely on accelerometer data
3. **Limited test coverage**: Unit tests for core business logic only
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

### Reusable Components

- **PrimaryActionButton**: Consistent button styling with haptic feedback
- **AnimationModifiers**: Reusable animations (pulsing, breathing)
- **TimeFormatter**: Centralized time formatting utilities
- **ComplicationViews**: SwiftUI views for all complication families

### Key Protocols

- **StateManager**: App state management abstraction
- **SensorDataProvider**: Sensor recording interface
- **AccelerometerDataHandler**: Data processing interface
- **NotificationService**: Notification management interface

### Important Notes

- Always compile after each significant change
- Test on multiple watch sizes (SE 40mm is most constrained)
- Update complications when app state changes
- Respect the 30-minute background execution limit
- Use singletons for services, not dependency injection containers