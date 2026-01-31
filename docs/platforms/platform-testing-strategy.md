# Platform Testing Strategy

This document outlines the testing approach for MCAL across all supported platforms. The strategy focuses on unit testing and manual verification to ensure quality across Linux, Android, iOS, macOS, Web, and Windows platforms.

## Testing Philosophy

MCAL uses a layered testing approach that balances automation with manual verification:

1. **Unit Tests**: Fast, focused tests for individual functions and classes
2. **Widget Tests**: Flutter widget tests for UI component behavior
3. **Manual Testing**: Platform-specific verification by developers and QA

## Unit Testing Coverage

Unit tests form the foundation of MCAL's test strategy:

- **Event Model Tests**: Event creation, validation, recurrence logic
- **Provider Tests**: State management logic and notifications
- **Repository Tests**: Data layer operations and caching
- **Utility Tests**: Date/time calculations, formatting, validation

These tests run on all platforms and provide fast feedback during development.

## Widget Testing

Flutter widget tests verify UI component behavior:

- Widget rendering and layout
- User interaction handling (taps, swipes, gestures)
- State changes and Provider integration
- Dialog and navigation behavior

Widget tests run efficiently without platform-specific emulators.

## Platform-Specific Manual Testing

Each platform has unique features that require manual verification:

### Android-Specific Features

- System back button behavior
- Runtime permission dialogs
- Notification channels and badges
- File picker integration
- Material Design 3 theming

### iOS-Specific Features

- Swipe-to-go-back gestures
- iOS permission presentation
- Background app refresh
- iOS sandbox file access
- Human Interface Guidelines compliance

### macOS-Specific Features

- Application bundle and Dock integration
- macOS system permissions
- Command+Q/W keyboard shortcuts
- Notification Center integration
- Traffic light window controls

### Linux-Specific Features

- XDG directory compliance
- Desktop notification integration
- Global theme support
- Desktop launcher integration

### Windows-Specific Features

- Start Menu integration
- Windows notification system
- Alt+F4 window closing
- Windows theming support

### Web-Specific Features

- Cross-browser compatibility (Chrome, Firefox, Safari, Edge)
- PWA installation (if applicable)
- Browser notification APIs
- Responsive design across screen sizes

## Testing Priorities

1. **Critical Path**: Event CRUD, calendar display, sync functionality
2. **Core Features**: Theme management, notifications, data persistence
3. **Platform Features**: Platform-specific integrations and UI conventions
4. **Edge Cases**: Error handling, empty states, large datasets

## Test Execution

- **Unit Tests**: Run on every commit (fast, < 1 minute)
- **Widget Tests**: Run on every commit (fast, < 2 minutes)
- **Manual Testing**: Before each release (varies by platform)
- **Platform Verification**: All platforms tested before major releases

## Quality Standards

All code contributions must include:

- [ ] Unit tests for new functionality
- [ ] Widget tests for new UI components
- [ ] Manual testing on target platforms
- [ ] Code quality checks pass (linting, formatting)
- [ ] No new linting warnings

This testing strategy ensures MCAL maintains high quality across all supported platforms while remaining practical for ongoing development.
