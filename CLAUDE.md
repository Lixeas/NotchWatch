# CLAUDE.md

## Overview

ClaudeNotchBar is a macOS application designed to monitor Anthropic API credit consumption for Enterprise accounts. It provides a visual representation of your credit usage in the menu bar (Notch area).

## Technical Architecture

### Key Components

1. **KeychainManager**: Handles secure retrieval of OAuth tokens from macOS Keychain
2. **APIService**: Manages communication with Anthropic API endpoints
3. **UsageTracker**: ObservableObject that manages credit data and refresh operations
4. **MenuBarExtra**: SwiftUI component that displays the credit information in the menu bar

### Data Flow

1. Application retrieves OAuth token from Keychain
2. APIService makes authenticated request to Anthropic API
3. UsageTracker processes the response and updates the UI
4. MenuBarExtra displays the current credit status

## Development Process

### Initial Setup

1. Created Xcode project with SwiftUI macOS app template
2. Established directory structure for Models, Services, Views, and Resources
3. Set up initial Package.swift configuration

### Core Implementation

1. Implemented KeychainManager with secure token retrieval
2. Developed APIService with proper authentication headers
3. Created UsageTracker as ObservableObject for state management
4. Built MenuBarExtra component with progress visualization

### Testing

1. Unit tests for KeychainManager functionality
2. Integration tests for API communication
3. UI tests for MenuBarExtra component

## Challenges and Solutions

### Challenge 1: Secure Token Retrieval

**Problem**: Needed to securely retrieve OAuth token from Keychain without exposing it in logs.

**Solution**: Implemented KeychainManager with proper error handling and data validation.

### Challenge 2: API Communication

**Problem**: Required proper authentication headers and error handling for API requests.

**Solution**: Developed APIService with proper request configuration and response handling.

### Challenge 3: Real-time Updates

**Problem**: Needed to provide real-time updates without excessive API calls.

**Solution**: Implemented UsageTracker with automatic refresh functionality.

## Future Enhancements

1. Add notification when credit threshold is reached
2. Implement historical credit usage tracking
3. Add support for multiple Anthropic accounts
4. Create customizable display options

## Contribution Guidelines

1. Follow standard GitHub flow for contributions
2. Maintain consistent code style and documentation
3. Write unit tests for new features
4. Document any changes in the CLAUDE.md file

## License

This project is licensed under the MIT License.
