# SleepPhaseWakeApp Memory Bank

## Project Overview

SleepPhaseWakeApp is a watchOS-only application designed to wake users during lighter sleep phases within a 30-minute window before their set alarm time. The app uses accelerometer data to detect movement patterns as a proxy for identifying sleep phases.

### Key Features
- Smart wake-up within 30-minute window before alarm
- Movement-based sleep phase detection
- watchOS complications for quick access
- Simulation mode for testing
- Clean, minimalist UI optimized for all Apple Watch sizes

## Architecture & Design Principles

### SOLID Principles Implementation

#### 1. Single Responsibility Principle (SRP)
Each class has one clear responsibility:
- `AppStateManager`: Manages app state persistence
- `AccelerometerService`: Handles sensor data recording
- `MovementDetector`: Processes accelerometer data for movement detection
- `UserNotificationService`: Manages all notifications
- `SleepSessionCoordinatorService`: Coordinates sleep session lifecycle
- `TimeFormatter`: Handles all time formatting logic

#### 2. Open/Closed Principle (OCP)
- Protocol-based design allows extension without modification
- New sensor types can be added by implementing `SensorDataProvider`
- New notification types can be added through `NotificationService` protocol

#### 3. Liskov Substitution Principle (LSP)
- All protocol implementations are interchangeable
- `AccelerometerService` can be replaced with any `SensorDataProvider`
- Test doubles can replace production implementations

#### 4. Interface Segregation Principle (ISP)
- Small, focused protocols:
  - `SensorDataProvider`: Only sensor recording methods
  - `AccelerometerDataHandler`: Only data processing
  - `NotificationService`: Only notification methods
  - `StateManager`: Only state management

#### 5. Dependency Inversion Principle (DIP)
- ViewModels depend on protocol abstractions, not concrete implementations
- Services are injected as singletons following Apple's recommendations
- Protocol-oriented programming throughout

### DRY (Don't Repeat Yourself) Implementation
- Reusable UI components in `Views/Components/`
- Centralized time formatting in `TimeFormatter`
- Shared animation modifiers in `AnimationModifiers`
- Common button styling in `PrimaryActionButton`

### Protocol-Oriented Programming (POP)
Following Apple's recommendations:
- Protocols define capabilities, not inheritance hierarchies
- Protocol extensions provide default implementations
- Protocols and their single implementations are kept in the same file
- Composition over inheritance

## Project Structure

```
SleepPhaseWakeApp/
├── SleepPhaseWakeApp WatchKit Extension/
│   ├── Services/                    # Business logic layer
│   │   ├── AppStateManager.swift    # State persistence (Singleton)
│   │   ├── AccelerometerService.swift # Sensor recording
│   │   ├── MovementDetector.swift   # Movement analysis
│   │   ├── UserNotificationService.swift # Notifications
│   │   └── SleepSessionCoordinatorService.swift # Session orchestration
│   │
│   ├── Screens/                     # MVVM Views and ViewModels
│   │   ├── NotStartedSession/       # Initial setup screen
│   │   ├── StartedSession/          # Active monitoring screen
│   │   └── FinishedSession/         # Wake-up completion screen
│   │
│   ├── Views/                       # Reusable UI components
│   │   └── Components/
│   │       ├── PrimaryActionButton.swift
│   │       └── AnimationModifiers.swift
│   │
│   ├── Utilities/                   # Helper classes
│   │   └── TimeFormatter.swift      # Centralized time formatting
│   │
│   ├── Protocols/                   # Protocol definitions
│   │   ├── SensorDataProvider.swift
│   │   ├── AccelerometerDataHandler.swift
│   │   ├── NotificationService.swift
│   │   └── StateManager.swift
│   │
│   ├── Complications/               # Watch face complications
│   │   ├── ComplicationController.swift
│   │   ├── ComplicationDataProvider.swift
│   │   └── ComplicationViews.swift
│   │
│   └── Helpers/                     # Extensions and utilities
│       ├── CMSensorDataList+Extension.swift
│       ├── Date+RawRepresentable.swift
│       └── View+Extensions.swift
│
├── SleepPhaseWakeAppTests/          # Unit tests
│   ├── MovementDetectorTests.swift
│   ├── AppStateManagerTests.swift
│   ├── TimeFormatterTests.swift
│   └── SleepSessionManagerTests.swift
│
└── Resources/                       # Assets and configuration
    ├── Assets.xcassets
    └── Info.plist
```

## Component Responsibilities

### Services Layer

#### AppStateManager (Singleton)
- **Purpose**: Centralized state management with persistence
- **Responsibilities**:
  - Manage app state (notStarted, started, finished)
  - Persist wake-up time and settings
  - Track session start/stop times
  - Handle simulation mode flag
- **Protocol**: Implements `StateManager`

#### AccelerometerService (Singleton)
- **Purpose**: Hardware sensor interface
- **Responsibilities**:
  - Start/stop accelerometer recording
  - Query recorded sensor data
  - Manage CMSensorRecorder lifecycle
- **Protocol**: Implements `SensorDataProvider`

#### MovementDetector
- **Purpose**: Movement analysis from sensor data
- **Responsibilities**:
  - Process accelerometer data
  - Detect significant movement (threshold: 1.2)
  - Return wake-up decision
- **Protocol**: Implements `AccelerometerDataHandler`

#### UserNotificationService (Singleton)
- **Purpose**: System notification management
- **Responsibilities**:
  - Request notification permissions
  - Schedule wake-up notifications
  - Send immediate alerts
  - Handle notification center
- **Protocol**: Implements `NotificationService`

#### SleepSessionCoordinatorService (Singleton)
- **Purpose**: Sleep tracking orchestration
- **Responsibilities**:
  - Manage WKExtendedRuntimeSession
  - Coordinate sensor recording
  - Process movement data during wake window
  - Trigger wake-up when conditions met
  - Handle 30-minute background execution limit

### ViewModels

#### NotStartedSessionViewModel
- Manages time picker selection
- Handles session start action
- Calculates wake-up date (today or tomorrow)
- Manages simulation mode toggle

#### StartedSessionViewModel
- Displays wake window (e.g., "06:30 - 07:00")
- Shows countdown timer
- Updates progress ring
- Handles session cancellation
- Monitors battery level

#### FinishedSessionViewModel
- Shows wake-up success message
- Displays actual vs planned wake time
- Provides contextual greeting
- Resets app state for next session

### Reusable Components

#### PrimaryActionButton
- Consistent button styling across app
- Haptic feedback on tap
- Customizable colors and labels
- Accessibility support

#### AnimationModifiers
- `pulsingAnimation()`: Breathing effect for active states
- `breathingAnimation()`: Gentle scale animation
- Consistent animation timing

#### TimeFormatter
- `formatTime()`: "07:30 AM" format
- `formatCountdown()`: "8h 45m" format
- Centralized date/time formatting logic

### Complications

#### ComplicationController
- CLKComplicationDataSource implementation
- Supports all complication families
- Provides timeline entries

#### ComplicationDataProvider
- Generates templates for each family
- Shows sleep state and wake time
- Updates based on app state

#### ComplicationViews
- SwiftUI views for modern complications
- Graphic corner, circular, rectangular support
- Progress indicators for active sessions

## Technical Implementation Details

### Background Execution
- Uses `WKExtendedRuntimeSession` for 30-minute background processing
- Starts recording when entering wake window
- Samples accelerometer data every second
- Triggers system alarm on movement detection

### Movement Detection Algorithm
```swift
let magnitude = sqrt(
    pow(data.acceleration.x, 2) +
    pow(data.acceleration.y, 2) +
    pow(data.acceleration.z, 2)
)
return magnitude > movementThreshold // 1.2
```

### State Management
- Three states: `notStarted`, `started`, `finished`
- Persisted using `@AppStorage`
- State transitions trigger UI updates via Combine

### Simulation Mode
- Reduces wake window to 30 seconds for testing
- Toggled via long press on main screen
- Indicated by rocket icon (🚀)

## Coding Standards

### Swift Style Guide
- Protocol-oriented programming preferred
- Singletons for shared services (no DependencyContainer)
- MVVM for UI architecture
- Combine for reactive updates

### File Headers
All new files include:
```swift
//
//  FileName.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on DATE.
//
```

### Testing
- Unit tests for business logic
- Focus on:
  - Movement detection accuracy
  - State management consistency
  - Time formatting correctness
  - Service behavior

## Future Enhancements

### Planned Features
1. **Enhanced Sleep Detection**
   - Heart rate integration
   - Movement frequency patterns
   - Apple HealthKit sleep stages

2. **iOS Companion App**
   - Detailed sleep analytics
   - Historical trends
   - Settings sync

3. **Improved UI**
   - Better support for SE 40mm screens
   - Dynamic type support
   - More complication families

4. **Advanced Algorithms**
   - Machine learning for personalized wake times
   - Sleep quality scoring
   - Smart alarm adjustment based on sleep debt

### Technical Debt
- Add comprehensive test coverage
- Implement proper error handling
- Add analytics for algorithm improvement
- Create onboarding flow

## Dependencies

### External
- **Sentry SDK (8.47.0)**: Crash reporting and performance monitoring
  - Integrated via Swift Package Manager
  - Used for production error tracking

### System Frameworks
- **WatchKit**: Core watch app functionality
- **CoreMotion**: Accelerometer access
- **ClockKit**: Complication support
- **UserNotifications**: Local notifications
- **Combine**: Reactive programming
- **SwiftUI**: Modern UI framework

## Build & Deployment

### Requirements
- Xcode 14.0+
- watchOS 9.0+
- Swift 5.7+

### Configuration
- Bundle ID: `ruslan.SleepPhase`
- Deployment Target: watchOS 9.0
- Supports: All Apple Watch models

### Build Commands
```bash
# Debug build
xcodebuild -project SleepPhaseWakeApp.xcodeproj \
  -scheme "SleepPhaseWakeApp WatchKit App" \
  -configuration Debug build

# Run tests
xcodebuild test -project SleepPhaseWakeApp.xcodeproj \
  -scheme "SleepPhaseWakeAppTests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch SE (44mm)'
```

## Architectural Decisions

### Why Singletons?
- Apple's recommended pattern for watchOS
- Simple lifecycle management
- No complex dependency injection needed
- Clear ownership and initialization

### Why No ViewModelBase?
- Unnecessary abstraction for simple app
- Each ViewModel has distinct responsibilities
- Reduces coupling between screens
- Easier to understand and maintain

### Why Protocol-Oriented?
- Testability through protocol mocking
- Flexibility for future implementations
- Clear contracts between components
- Aligns with Swift best practices

### Why 30-Minute Window?
- watchOS background execution limit
- Balance between battery life and effectiveness
- Sufficient time to detect light sleep phases
- User expectation alignment

## Maintenance Guidelines

### Adding New Features
1. Define protocol if introducing new capability
2. Implement as singleton service if shared
3. Create focused ViewModel for new screens
4. Extract reusable UI into Components
5. Add unit tests for business logic

### Code Review Checklist
- [ ] Follows SOLID principles
- [ ] No code duplication (DRY)
- [ ] Protocol-oriented design
- [ ] Proper error handling
- [ ] Unit tests included
- [ ] Accessibility support
- [ ] All watch sizes supported

### Performance Considerations
- Minimize battery usage during sleep
- Efficient sensor data processing
- Lazy loading where appropriate
- Proper memory management
- Background task optimization

## Contact & Support

**Author**: Ruslan Popesku
**Project**: SleepPhaseWakeApp
**Platform**: watchOS
**License**: Proprietary

For questions or contributions, please follow the coding standards and architectural principles outlined in this document.