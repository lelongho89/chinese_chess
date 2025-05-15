# React Native Dependencies for Chinese Chess

This document outlines the key dependencies needed for the React Native implementation of the Chinese Chess application.

## Core Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| `react` | ^18.2.0 | Core React library |
| `react-native` | ^0.73.0 | React Native framework |
| `react-native-web` | ^0.19.0 | Web support for React Native |

## Navigation

| Dependency | Version | Purpose |
|------------|---------|---------|
| `@react-navigation/native` | ^6.1.9 | Navigation container and utilities |
| `@react-navigation/stack` | ^6.3.20 | Stack-based navigation |
| `@react-navigation/bottom-tabs` | ^6.5.11 | Tab-based navigation |
| `@react-navigation/drawer` | ^6.6.6 | Drawer-based navigation |
| `react-native-screens` | ^3.29.0 | Native navigation primitives |
| `react-native-safe-area-context` | ^4.8.2 | Safe area utilities |
| `react-native-gesture-handler` | ^2.14.0 | Gesture handling for navigation |

## State Management

| Dependency | Version | Purpose |
|------------|---------|---------|
| `redux` | ^5.0.1 | State management library |
| `react-redux` | ^9.0.4 | React bindings for Redux |
| `@reduxjs/toolkit` | ^2.0.1 | Utilities for Redux |
| `redux-persist` | ^6.0.0 | Persist and rehydrate Redux store |

## Firebase Integration

| Dependency | Version | Purpose |
|------------|---------|---------|
| `@react-native-firebase/app` | ^18.7.3 | Firebase core functionality |
| `@react-native-firebase/auth` | ^18.7.3 | Firebase authentication |
| `@react-native-firebase/firestore` | ^18.7.3 | Cloud Firestore database |
| `@react-native-firebase/storage` | ^18.7.3 | Firebase storage for assets |
| `@react-native-firebase/analytics` | ^18.7.3 | Firebase analytics |
| `@react-native-firebase/messaging` | ^18.7.3 | Firebase cloud messaging |

## UI Components

| Dependency | Version | Purpose |
|------------|---------|---------|
| `react-native-vector-icons` | ^10.0.3 | Icon library |
| `react-native-paper` | ^5.11.6 | Material Design components |
| `react-native-reanimated` | ^3.6.1 | Advanced animations |
| `react-native-svg` | ^14.1.0 | SVG support |
| `react-native-modal` | ^13.0.1 | Enhanced modal component |
| `react-native-toast-message` | ^2.2.0 | Toast notifications |

## Localization

| Dependency | Version | Purpose |
|------------|---------|---------|
| `i18next` | ^23.7.16 | Internationalization framework |
| `react-i18next` | ^14.0.0 | React bindings for i18next |
| `react-native-localize` | ^3.0.4 | Device locale detection |

## Storage

| Dependency | Version | Purpose |
|------------|---------|---------|
| `@react-native-async-storage/async-storage` | ^1.21.0 | Asynchronous storage |
| `react-native-fs` | ^2.20.0 | File system access |
| `react-native-share` | ^10.0.2 | Share content |

## Audio

| Dependency | Version | Purpose |
|------------|---------|---------|
| `react-native-sound` | ^0.11.2 | Sound playback |
| `react-native-track-player` | ^4.0.1 | Background audio |

## Networking

| Dependency | Version | Purpose |
|------------|---------|---------|
| `axios` | ^1.6.5 | HTTP client |
| `socket.io-client` | ^4.7.3 | WebSocket client |

## Utilities

| Dependency | Version | Purpose |
|------------|---------|---------|
| `lodash` | ^4.17.21 | Utility functions |
| `date-fns` | ^3.2.0 | Date manipulation |
| `uuid` | ^9.0.1 | UUID generation |
| `react-native-device-info` | ^10.12.0 | Device information |

## Development Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| `@babel/core` | ^7.23.7 | Babel core |
| `@babel/runtime` | ^7.23.7 | Babel runtime |
| `@react-native/eslint-config` | ^0.73.2 | ESLint configuration |
| `@react-native/metro-config` | ^0.73.5 | Metro configuration |
| `@types/react` | ^18.2.47 | TypeScript definitions for React |
| `@types/react-test-renderer` | ^18.0.7 | TypeScript definitions for test renderer |
| `babel-jest` | ^29.7.0 | Jest transformer for Babel |
| `eslint` | ^8.56.0 | Linting utility |
| `jest` | ^29.7.0 | Testing framework |
| `metro-react-native-babel-preset` | ^0.77.0 | Babel preset for React Native |
| `prettier` | ^3.1.1 | Code formatter |
| `react-test-renderer` | ^18.2.0 | Test renderer for React |
| `typescript` | ^5.3.3 | TypeScript language |

## Game-Specific Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| `react-native-game-engine` | ^1.2.0 | Game loop and entity-component system |
| `matter-js` | ^0.19.0 | 2D physics engine |
| `react-native-haptic-feedback` | ^2.2.0 | Haptic feedback |

## Installation

To install all dependencies, run:

```bash
# Core dependencies
npm install react react-native react-native-web

# Navigation
npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs @react-navigation/drawer react-native-screens react-native-safe-area-context react-native-gesture-handler

# State management
npm install redux react-redux @reduxjs/toolkit redux-persist

# Firebase
npm install @react-native-firebase/app @react-native-firebase/auth @react-native-firebase/firestore @react-native-firebase/storage @react-native-firebase/analytics @react-native-firebase/messaging

# UI Components
npm install react-native-vector-icons react-native-paper react-native-reanimated react-native-svg react-native-modal react-native-toast-message

# Localization
npm install i18next react-i18next react-native-localize

# Storage
npm install @react-native-async-storage/async-storage react-native-fs react-native-share

# Audio
npm install react-native-sound react-native-track-player

# Networking
npm install axios socket.io-client

# Utilities
npm install lodash date-fns uuid react-native-device-info

# Game-specific
npm install react-native-game-engine matter-js react-native-haptic-feedback

# Development dependencies
npm install --save-dev @babel/core @babel/runtime @react-native/eslint-config @react-native/metro-config @types/react @types/react-test-renderer babel-jest eslint jest metro-react-native-babel-preset prettier react-test-renderer typescript
```

## Configuration

After installing these dependencies, you'll need to:

1. Link native dependencies (React Native 0.60+ uses autolinking)
2. Configure Firebase for iOS and Android
3. Set up vector icons
4. Configure navigation

### iOS Configuration

For iOS, you'll need to install pods:

```bash
cd ios
pod install
cd ..
```

### Android Configuration

For Android, you may need to update the `android/app/build.gradle` file to include specific configurations for some libraries.

## Notes

- Version numbers are current as of December 2023 and should be updated as needed
- Some dependencies may require additional configuration or native code changes
- Always check the official documentation for each library for the most up-to-date installation instructions
