# NotchWatch - Specifications

## Overview
NotchWatch is a macOS application that displays Anthropic API usage credits in the menu bar (Notch area). It provides real-time monitoring of your Anthropic API credit consumption for Enterprise accounts.

## Technical Specifications

### System Requirements
- macOS 13.0 or later
- Swift 5.9 or later
- Xcode 15.0 or later

### Dependencies
- SwiftUI for UI components
- Security framework for Keychain access
- URLSession for API communication

## Implementation Plan

### Phase 1: Project Setup
1. Initialize Xcode project with SwiftUI macOS app template
2. Set up directory structure:
   - Models/
   - Services/
   - Views/
   - Resources/

### Phase 2: Core Functionality
1. Implement KeychainManager to securely retrieve OAuth token
2. Create APIService for Anthropic API communication
3. Develop UsageTracker as ObservableObject for data management
4. Build MenuBarExtra view for display in Notch area

### Phase 3: UI Components
1. Create progress bar for credit visualization
2. Implement refresh button functionality
3. Add error handling and loading states

### Phase 4: Testing
1. Unit tests for KeychainManager
2. Integration tests for APIService
3. UI tests for MenuBarExtra

### Phase 5: Deployment
1. Package as macOS application
2. Create installation instructions
3. Prepare release notes
