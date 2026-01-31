# Cross-Platform Manual Testing Checklist

This checklist contains platform-specific features that require manual testing on each platform before release. All items should be tested and verified as working.

## Android Manual Testing Checklist

### System Navigation
- [ ] Back button closes dialogs when pressed
- [ ] Back button in main screen doesn't close app unexpectedly
- [ ] Back button navigates correctly through app screens
- [ ] System navigation bar integration works with app theme

### Permissions
- [ ] Notification permissions requested on first launch
- [ ] Permission dialogs use system-standard presentation
- [ ] Permissions are properly persisted after grant
- [ ] File system permissions requested when needed
- [ ] Permission denied state is handled gracefully

### Notifications
- [ ] Notifications appear in Android notification shade
- [ ] Notification channel is properly configured (importance: high/default)
- [ ] Notification badges appear on launcher icon
- [ ] Notification actions (tapping notification) open app correctly
- [ ] Notifications are grouped appropriately for multiple events
- [ ] Notification sound/vibration plays according to settings
- [ ] Clearing notification from shade dismisses in-app notification

### File System
- [ ] File picker opens correctly when selecting certificates
- [ ] File picker handles storage permissions appropriately
- [ ] Selected file path is correctly processed by app
- [ ] App can read files from external storage (if applicable)
- [ ] App can write files to external storage (if applicable)

### UI/UX
- [ ] Material Design 3 guidelines followed
- [ ] Status bar color matches app theme
- [ ] Navigation bar color matches app theme
- [ ] Text scaling respects system font size settings
- [ ] Dark mode toggle works and persists
- [ ] App respects system dark mode setting (when in system theme mode)

### Performance
- [ ] App launches within 3 seconds on target devices
- [ ] Scrolling event list with 100+ events is smooth (60fps)
- [ ] Calendar navigation between months is smooth
- [ ] Dialogs open and close without visible lag
- [ ] Animations run at 60fps on target devices

## iOS Manual Testing Checklist

### Navigation
- [ ] Swipe-from-left-edge gesture closes dialogs
- [ ] Swipe gesture works consistently across all dialogs
- [ ] Navigation bar doesn't interfere with app gestures
- [ ] Back button in navigation bar works as expected

### Permissions
- [ ] Notification permissions presented in iOS system dialog
- [ ] Permission prompts use iOS-appropriate messaging
- [ ] Permissions are properly persisted after grant
- [ ] Permission denied state shows user-friendly error message
- [ ] Background app refresh permissions are requested appropriately

### Background Execution
- [ ] App continues to sync in background with iOS permissions
- [ ] Background fetch respects iOS battery optimization settings
- [ ] Silent push notifications work correctly
- [ ] App state restoration after background sync works correctly

### File System
- [ ] File picker respects iOS app sandbox
- [ ] File operations work within iOS containerized storage
- [ ] iCloud Drive integration works (if enabled)
- [ ] Document picker integration works (if enabled)

### Notifications
- [ ] Notifications appear on lock screen
- [ ] Notifications appear in Notification Center
- [ ] Notifications appear as banners when app is in use
- [ ] Notification actions (tapping) open app correctly
- [ ] Notifications are grouped appropriately
- [ ] Clearing notification from Notification Center dismisses in-app notification
- [ ] Notification sounds/vibration play according to iOS settings
- [ ] Notifications respect Do Not Disturb settings

### UI/UX
- [ ] iOS Human Interface guidelines followed
- [ ] Status bar color matches app theme
- [ ] Navigation bar is hidden when appropriate
- [ ] Dynamic Type (text scaling) works correctly
- [ ] Haptic feedback is provided for important actions
- [ ] Dark mode toggle works and persists
- [ ] App respects system dark mode setting (when in system theme mode)

### Performance
- [ ] App launches within 2 seconds on target devices
- [ ] Scrolling is smooth at 60fps
- [ ] Calendar navigation is smooth
- [ ] Trans/animations don't have visible lag
- [ ] App respects iOS background execution limits

## Linux Manual Testing Checklist

### Desktop Integration
- [ ] App integrates with Linux desktop environment (icons, launchers)
- [ ] App launches from terminal or desktop menu
- [ ] Keyboard shortcuts work correctly (Ctrl+Q to quit, etc.)
- [ ] App respects global theme settings (if applicable)

### File System
- [ ] App uses XDG directories correctly
- [ ] File permissions work correctly on Linux
- [ ] App can read/write in user home directory
- [ ] Configuration files stored in appropriate location

### Notifications
- [ ] Desktop notifications work correctly
- [ ] Notification actions launch app correctly
- [ ] Notification clearing works properly
- [ ] Notifications are properly dismissed from system notification center

### UI/UX
- [ ] App window can be resized
- [ ] App window position is restored on relaunch
- [ ] App maximizes/minimizes correctly
- [ ] Dark mode toggle works and persists
- [ ] App respects system dark mode setting (when in system theme mode)

### Performance
- [ ] App launches quickly (< 2 seconds)
- [ ] Scrolling is smooth
- [ ] Calendar navigation is smooth
- [ ] App uses reasonable memory (< 200MB with 100 events)

## macOS Manual Testing Checklist

### Desktop Integration
- [ ] App has proper macOS application bundle
- [ ] App appears in Applications folder
- [ ] App icon appears correctly in Dock
- [ ] App menu (when clicking icon) works
- [ ] App responds to Cmd+Q quit command
- [ ] App responds to Cmd+W close window command
- [ ] App shows in Cmd+Tab app switcher

### Permissions
- [ ] Notification permissions presented in macOS system dialog
- [ ] Accessibility permissions work correctly
- [ ] File system permissions work correctly
- [ ] Full Disk Access requested appropriately (if needed)

### File System
- [ ] App respects macOS sandbox
- [ ] File picker works correctly
- [ ] App can read/write in ~/Library/Application Support/
- [ ] iCloud Drive integration works (if enabled)

### Notifications
- [ ] Notifications appear in Notification Center
- [ ] Notification banners appear when app is in use
- [ ] Notification actions work correctly
- [ ] Notification sounds/vibration work according to macOS settings
- [ ] Notifications respect Do Not Disturb settings

### UI/UX
- [ ] macOS Human Interface guidelines followed
- [ ] Traffic light buttons (red/yellow/green) work correctly
- [ ] App window position/size restored on relaunch
- [ ] App respects system dark mode setting (when in system theme mode)
- [ ] Text scaling works correctly

### Performance
- [ ] App launches quickly (< 2 seconds)
- [ ] Scrolling is smooth at 60fps
- [ ] App uses reasonable memory (< 250MB with 100 events)

## Web Manual Testing Checklist

### Browser Integration
- [ ] App runs in Chrome, Firefox, Safari, Edge
- [ ] PWA installation works (if applicable)
- [ ] App icon displays correctly in browser tab
- [ ] Page title displays correctly

### File System
- [ ] File upload/download works through browser APIs
- [ ] Certificate file upload works correctly
- [ ] Export functionality downloads files correctly

### Notifications
- [ ] Browser notifications work correctly
- [ ] Notification permissions requested and granted
- [ ] Notification actions launch app/tab correctly
- [ ] Notifications persist across browser sessions
- [ ] Notification sounds play (if supported by browser)

### UI/UX
- [ ] Responsive layout works on different screen sizes
- [ ] Mobile layout works on small screens (< 768px)
- [ ] Desktop layout works on large screens (> 1024px)
- [ ] Touch interactions work correctly on mobile devices
- [ ] Mouse/keyboard interactions work correctly on desktop
- [ ] Dark mode toggle works and persists (using localStorage)
- [ ] App respects system dark mode setting (if detectable)
- [ ] Scrollbars appear when needed

### Performance
- [ ] Initial load completes in < 3 seconds
- [ ] Scrolling is smooth at 60fps
- [ ] App doesn't cause excessive memory usage in browser
- [ ] Animations perform well on different devices

## Windows Manual Testing Checklist

### Desktop Integration
- [ ] App has proper Windows application package
- [ ] App appears in Start Menu
- [ ] App shortcut can be pinned to taskbar
- [ ] App icon displays correctly
- [ ] App responds to Alt+F4 close window command

### File System
- [ ] App uses Windows file system correctly
- [ ] File picker works correctly
- [ ] App can read/write in AppData directory
- [ ] File permissions work correctly

### Notifications
- [ ] Windows toast notifications work correctly
- [ ] Notifications appear in Action Center
- [ ] Notification actions work correctly
- [ ] Notification sounds play correctly

### UI/UX
- [ ] Windows design guidelines followed (if applicable)
- [ ] App window position/size restored on relaunch
- [ ] App maximizes/minimizes correctly
- [ ] Dark mode toggle works and persists
- [ ] App respects system dark mode setting (when in system theme mode)
- [ ] Title bar color matches app theme

### Performance
- [ ] App launches quickly (< 3 seconds)
- [ ] Scrolling is smooth at 60fps
- [ ] App uses reasonable memory (< 300MB with 100 events)

## Cross-Platform Functional Testing

### Sync Functionality
- [ ] Sync works with HTTPS Git repositories
- [ ] Sync works with SSH Git repositories
- [ ] Certificate authentication works correctly
- [ ] Username/password authentication works correctly
- [ ] Auto-sync works when enabled
- [ ] Manual sync (pull/push) works correctly
- [ ] Sync conflicts are handled correctly
- [ ] Sync status displays correctly

### Event Management
- [ ] Event creation works on all platforms
- [ ] Event editing works on all platforms
- [ ] Event deletion works on all platforms
- [ ] Recurring events work correctly on all platforms
- [ ] Multi-day events work correctly on all platforms
- [ ] All-day events work correctly on all platforms

### Data Persistence
- [ ] Events persist across app restarts on all platforms
- [ ] Sync settings persist across app restarts on all platforms
- [ ] Theme settings persist across app restarts on all platforms
- [ ] Credentials persist securely across app restarts on all platforms

### Accessibility
- [ ] Screen reader works correctly on all platforms
- [ ] Keyboard navigation works correctly
- [ ] Touch targets meet minimum size requirements on all platforms
- [ ] Semantic labels are correctly set

## Release Verification

Before each release, ensure:

- [ ] All platform-specific tests have been completed
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] Code quality checks pass (linting, formatting)
- [ ] Known platform-specific issues are documented in release notes
- [ ] Manual testing results are reviewed by QA team
