# Chinese Chess: Flutter to React Native Migration Plan

## Overview

This document outlines the step-by-step process for migrating the Chinese Chess application from Flutter to React Native. The migration will be done on the `react-native-migration` branch, allowing for parallel development and testing without affecting the main Flutter codebase.

## Prerequisites

Before starting the migration, ensure you have the following tools installed:

- Node.js (v16 or later)
- npm (v8 or later) or Yarn (v1.22 or later)
- React Native CLI
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)
- Git

## Phase 1: Project Setup and Environment Configuration

### 1.1 Initialize React Native Project

```bash
# Navigate to a temporary directory
mkdir -p ~/temp/chinese_chess_rn
cd ~/temp/chinese_chess_rn

# Initialize a new React Native project
npx react-native@latest init ChineseChessRN

# Copy the new project to our repository
cp -R ChineseChessRN/* /path/to/chinese_chess/
```

### 1.2 Configure Project Structure

Create the following directory structure:

```
src/
├── assets/
│   ├── images/
│   ├── sounds/
│   └── skins/
├── components/
│   ├── board/
│   ├── pieces/
│   └── ui/
├── screens/
├── navigation/
├── hooks/
├── utils/
├── services/
│   ├── firebase/
│   ├── game/
│   └── audio/
├── store/
│   ├── actions/
│   ├── reducers/
│   └── selectors/
└── localization/
```

### 1.3 Set Up Dependencies

Add the following essential dependencies:

```bash
# Navigation
npm install @react-navigation/native @react-navigation/stack
npm install react-native-screens react-native-safe-area-context

# State Management
npm install redux react-redux @reduxjs/toolkit

# Firebase
npm install @react-native-firebase/app @react-native-firebase/auth @react-native-firebase/firestore

# UI Components
npm install react-native-vector-icons
npm install react-native-gesture-handler

# Localization
npm install i18next react-i18next

# Sound
npm install react-native-sound

# Storage
npm install @react-native-async-storage/async-storage
```

## Phase 2: Core Game Components Migration

### 2.1 Game Board Implementation

1. Create the board component:
   - Implement the 9x10 grid layout
   - Add board background with customizable skins
   - Implement board flipping functionality

2. Chess Pieces:
   - Create components for each piece type
   - Implement piece movement and animation
   - Add support for different skins

### 2.2 Game Logic

1. Port the core game logic from Flutter:
   - Move validation
   - Game state management
   - Win/loss detection

2. Implement game modes:
   - AI opponent (port existing AI logic)
   - Local multiplayer
   - Online multiplayer

### 2.3 State Management

1. Set up Redux store:
   - Game state reducer
   - User settings reducer
   - Authentication reducer

2. Create actions for:
   - Making moves
   - Starting/ending games
   - Changing settings
   - User authentication

## Phase 3: Firebase Integration

### 3.1 Authentication

1. Configure Firebase authentication:
   - Email/password login
   - Social login (Google, Facebook)
   - User profile management

2. Create authentication screens:
   - Login
   - Registration
   - Password reset
   - Profile editing

### 3.2 Firestore Integration

1. Set up Firestore collections:
   - Users
   - Games
   - Tournaments

2. Implement data synchronization:
   - Real-time game updates
   - User statistics
   - Game history

### 3.3 Real-time Game Synchronization

1. Implement WebSocket connection for real-time gameplay
2. Synchronize game state between players
3. Handle disconnections and reconnections

## Phase 4: Game Features

### 4.1 Timer System

1. Implement the chess timer:
   - Blitz format (3+2)
   - Timer display
   - Time control logic

2. Server synchronization for online games

### 4.2 Skin System

1. Port the existing skin system:
   - Woods skin
   - Stones skin
   - Skin selection UI

2. Optimize assets for React Native

### 4.3 Localization

1. Set up i18next for localization:
   - English
   - Chinese
   - Vietnamese

2. Create translation files for all UI elements

### 4.4 Game Modes

1. Implement game mode selection:
   - AI mode
   - Online mode
   - Free play mode

2. Create mode-specific UI and controls

## Phase 5: Testing and Quality Assurance

### 5.1 Unit Testing

1. Set up Jest for unit testing
2. Write tests for:
   - Game logic
   - Redux reducers
   - Utility functions

### 5.2 Component Testing

1. Test UI components with React Native Testing Library
2. Verify component rendering and interactions

### 5.3 Integration Testing

1. Create end-to-end tests for main user flows:
   - Game play
   - Authentication
   - Settings changes

### 5.4 Performance Optimization

1. Analyze and optimize render performance
2. Reduce bundle size
3. Optimize asset loading

## Phase 6: Deployment

### 6.1 iOS Deployment

1. Configure iOS build settings
2. Set up App Store Connect
3. Prepare screenshots and metadata
4. Submit for review

### 6.2 Android Deployment

1. Configure Android build settings
2. Set up Google Play Console
3. Prepare screenshots and metadata
4. Submit for review

## Timeline

- Phase 1: 1 week
- Phase 2: 3 weeks
- Phase 3: 2 weeks
- Phase 4: 2 weeks
- Phase 5: 1 week
- Phase 6: 1 week

Total estimated time: 10 weeks

## Migration Checklist

- [ ] Project setup complete
- [ ] Board and pieces implemented
- [ ] Game logic ported
- [ ] Firebase authentication working
- [ ] Firestore integration complete
- [ ] Real-time gameplay functional
- [ ] Timer system implemented
- [ ] Skin system ported
- [ ] Localization working
- [ ] All game modes implemented
- [ ] Tests passing
- [ ] Performance optimized
- [ ] Ready for deployment
