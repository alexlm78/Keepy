# Keepy

<p align="center">
  <strong>A lightweight macOS menu bar utility for clipboard history, temporary files, and quick notes</strong>
</p>

## Overview

Keepy ( Your digital space to store what matters ) is a native macOS menu bar application designed to enhance productivity by providing quick access to:

- **Clipboard History**: Automatic monitoring and storage of clipboard content (text, URLs, images, files)
- **Temporary File Management**: Store and manage temporary files with configurable expiration policies
- **Quick Notes**: Simple note-taking with tags, colors, and pinning capabilities

The app lives exclusively in the menu bar with no Dock presence, providing a clean and unobtrusive user experience accessible via click or global shortcuts.

## Features

### Implemented

#### Menu Bar Integration
- Custom menu bar icon with template rendering
- Popover interface (400x600) accessible via left-click
- Context menu with Settings and Quit options (right-click)
- Transient popover behavior (closes when clicking outside)

#### Clipboard History
- Automatic clipboard monitoring using timer-based polling (0.5s intervals)
- Support for multiple content types:
  - Plain text
  - URLs
  - Images (PNG/TIFF)
  - File paths
- Duplicate detection to avoid consecutive duplicates
- Favorite items functionality
- Persistent storage (~/.Library/Application Support/Keepy/clipboard_history.json)
- Maximum 1000 items in history
- Copy-to-clipboard functionality from history

#### User Interface
- Tab-based navigation with 4 sections:
  - Clipboard (clipboard history viewer)
  - Files (temporary file management)
  - Notes (quick note-taking)
  - Settings (app configuration)
- Multi-language support with LocalizationManager
- System language detection and auto-refresh on language changes

#### Temporary File Management
- Basic structure implemented (TemporaryFileManager)
- Automatic cleanup scheduler for expired files
- Session-based file cleanup on app termination

### In Development

- Complete Temporary File Management UI
- Enhanced Notes system with tags and colors
- Global keyboard shortcuts (HotKey support)
- Search functionality across clipboard history and notes
- Settings UI for:
  - Clipboard history limits
  - File expiration policies
  - Keyboard shortcut configuration
  - UI preferences

## Requirements

- macOS 26.0 or later
- Xcode 16.0+ (for building from source)
- Swift 5.0+

## Building from Source

### Using Xcode

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Keepy.git
   cd Keepy
   ```

2. Open the project:
   ```bash
   open Keepy.xcodeproj
   ```

3. Build and run from Xcode (Cmd+R)

### Using Command Line

Build for Debug:
```bash
xcodebuild -project Keepy.xcodeproj -scheme Keepy -configuration Debug build
```

Build for Release:
```bash
xcodebuild -project Keepy.xcodeproj -scheme Keepy -configuration Release build
```

Run the app:
```bash
open build/Release/Keepy.app
```

## Architecture

### Core Components

**AppDelegate** (`KeepyApp.swift`)
- Creates and manages NSStatusItem in menu bar
- Handles popover lifecycle and display
- Manages right-click context menu
- Initializes monitoring and cleanup systems on launch

**Managers**
- `ClipboardManager`: Monitors NSPasteboard changes via timer polling
- `TemporaryFileManager`: Manages file lifecycle with scheduled cleanup
- `LocalizationManager`: Handles multi-language support

**Views**
- `MenuBarPopover`: Main tab-based interface container
- `ClipboardView`: Displays clipboard history items
- `TemporaryFilesView`: File management interface
- `NotesView`: Note-taking interface
- `SettingsView`: App configuration

### Data Persistence

All data is stored in JSON format at:
```
~/Library/Application Support/Keepy/
├── clipboard_history.json
├── temporary_files.json (planned)
└── notes.json (planned)
```

## Configuration

- **Bundle Identifier**: `dev.kreaker.Keepy`
- **Deployment Target**: macOS 26.0
- **Sandbox**: Enabled with read-only user-selected files permission
- **LSUIElement**: Enabled (hides from Dock)

## Development Notes

### Key Implementation Details

**Clipboard Monitoring**
- Uses Timer-based polling since macOS lacks native clipboard change notifications
- Checks `NSPasteboard.changeCount` every 0.5 seconds for efficiency
- Automatic duplicate detection prevents redundant history entries

**Menu Bar Lifecycle**
- Single popover instance created on launch and reused
- Avoids `makeKey()` on NSStatusBarWindow to prevent warnings
- Uses `.transient` behavior for auto-dismiss on focus loss

**Data Flow**
1. Managers monitor changes (clipboard, file expiry)
2. SwiftUI views observe managers via `@Published` properties
3. Changes trigger automatic JSON persistence

### Testing the App

When testing, verify:
- App appears only in menu bar, not Dock
- Clipboard detection works across all applications
- Popover displays correctly below menu bar icon
- Data persists across app restarts
- Right-click context menu functions correctly

## Roadmap

- [ ] Complete Temporary File Management system
- [ ] Enhanced Notes with tags, colors, and pinning
- [ ] Global keyboard shortcuts (Carbon API integration)
- [ ] Advanced search and filtering
- [ ] Settings UI implementation
- [ ] Export/import functionality
- [ ] Automated tests
- [ ] Application signing and notarization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License

## Author

Alejandro Lopez Monzon

---

**Note**: This project is under active development. Some features mentioned in the architecture may not be fully implemented yet. See the "Implemented" vs "In Development" sections for current status.
