# Chinese Chess (Xiangqi) - React Native

A modern implementation of the traditional Chinese Chess (Xiangqi) game built with React Native.

***Important Note: This project is for learning and research purposes only. The images and sound resources are from "Chinese Chess Wizard" (象棋小巫师), and the built-in engine is translated from xqlite (JS). Please do not use these resources for commercial projects.***

## Overview

This is a React Native implementation of Chinese Chess, migrated from the original Flutter-based application. The project aims to provide a cross-platform mobile experience with a clean, modern UI and robust game mechanics.

## Platforms

- [x] Android
- [x] iOS
- [x] Web (React Native Web)

## Features

- Multiple game modes (AI, local multiplayer, online)
- Customizable board themes and piece sets
- Game history and replay functionality
- User authentication with Firebase
- Online multiplayer with real-time updates
- Comprehensive game rules implementation
- Timer system for competitive play
- Internationalization support

## Getting Started

### Prerequisites

- Node.js (v16 or later)
- npm (v8 or later) or Yarn (v1.22 or later)
- React Native CLI
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

### Installation

1. Clone this repository
```bash
git clone https://github.com/lelongho89/chinese_chess.git
cd chinese_chess
```

2. Install dependencies
```bash
npm install
```

3. Install iOS dependencies
```bash
cd ios && pod install && cd ..
```

4. Run the application
```bash
# For iOS
npm run ios

# For Android
npm run android
```

## Project Structure

```
src/
├── assets/                 # Static assets (images, sounds, etc.)
│   ├── images/            # UI images
│   ├── sounds/            # Game sounds
│   └── skins/             # Board and piece skins
├── components/            # Reusable UI components
│   ├── board/             # Chess board components
│   ├── pieces/            # Chess piece components
│   └── ui/                # General UI components
├── screens/               # Screen components
├── navigation/            # Navigation configuration
├── hooks/                 # Custom React hooks
├── utils/                 # Utility functions
├── services/              # Business logic services
│   ├── firebase/          # Firebase integration
│   ├── game/              # Game logic
│   └── audio/             # Audio management
├── store/                 # State management
│   ├── actions/           # Redux actions
│   ├── reducers/          # Redux reducers
│   └── slices/            # Redux Toolkit slices
└── localization/          # Internationalization
```

## Documentation

- [Business Logic Documentation](Buss.md) - Detailed description of game features and business logic
- [Technical Documentation](Technical.md) - Technical implementation details and architecture

## Game Rules

Chinese Chess (Xiangqi) is played on a 9×10 board with the following pieces:

- General/King (将/帅) - Moves one step orthogonally within the palace
- Advisor/Guard (士/仕) - Moves one step diagonally within the palace
- Elephant/Minister (象/相) - Moves exactly two points diagonally, cannot cross the river
- Horse/Knight (马/馬) - Moves one point orthogonally followed by one point diagonally outward
- Chariot/Rook (车/車) - Moves any distance orthogonally
- Cannon (炮/砲) - Moves like the Chariot when not capturing, must jump over exactly one piece to capture
- Soldier/Pawn (兵/卒) - Moves one point forward before crossing the river, can move horizontally after crossing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Original Flutter implementation contributors
- Chinese Chess Wizard (象棋小巫师) for the visual assets
- xqlite for the AI engine implementation
