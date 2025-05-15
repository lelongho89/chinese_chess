# Chinese Chess (Xiangqi) - React Native Version

A modern implementation of the traditional Chinese Chess (Xiangqi) game built with React Native.

***Important Note: This project is for learning and research purposes only. The images and sound resources are from "Chinese Chess Wizard" (象棋小巫师), and the built-in engine is translated from xqlite (JS). Please do not use these resources for commercial projects.***

## Migration Status

This branch contains the React Native migration of the original Flutter-based Chinese Chess application. The migration is a work in progress and follows the plan outlined in [MIGRATION_PLAN.md](MIGRATION_PLAN.md).

## Platforms

- [x] Android
- [x] iOS
- [x] Web (React Native Web)

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
git clone https://github.com/yourusername/chinese_chess.git
```

2. Navigate to the project directory
```bash
cd chinese_chess
```

3. Switch to the React Native branch
```bash
git checkout react-native-migration
```

4. Install dependencies
```bash
npm install
```

5. Install iOS dependencies
```bash
cd ios && pod install && cd ..
```

6. Run the app
```bash
# For iOS
npm run ios

# For Android
npm run android

# For Web
npm run web
```

## Project Structure

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

## Features

- [x] Local gameplay with traditional Chinese Chess rules
- [x] Multiple game modes (AI opponent, local multiplayer, online multiplayer)
- [x] User authentication and profiles
- [x] Customizable skins for board and pieces
- [x] Game history and replay
- [x] Elo rating system for ranked matches
- [x] Tournament system
- [x] Multilingual support (English, Chinese, Vietnamese)

## Game Modes

### AI Mode

Play against an AI opponent with adjustable difficulty levels. The AI uses a combination of minimax algorithm with alpha-beta pruning and evaluation heuristics.

### Online Mode

Play against other players online with real-time game synchronization. Features include:

- Matchmaking based on Elo rating
- Game chat
- Move timer
- Game history recording

### Free Mode

Practice mode where you can:
- Set up custom board positions
- Analyze games
- Try different strategies

## Customization

### Skins

The game includes multiple skins for the board and pieces:

- Woods (traditional wooden board and pieces)
- Stones (stone-themed board and pieces)

### Settings

Customize your game experience with various settings:

- Sound effects volume
- Music volume
- Language selection
- Notification preferences
- Board orientation

## Development

### Key Technologies

- React Native for cross-platform mobile development
- Redux for state management
- Firebase for backend services
- Socket.IO for real-time game synchronization
- i18next for localization

### Building

```bash
# Build for iOS
npm run build:ios

# Build for Android
npm run build:android

# Build for Web
npm run build:web
```

### Testing

```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Run e2e tests
npm run test:e2e
```

## Migration Documents

The following documents provide guidance for the React Native migration:

- [MIGRATION_PLAN.md](MIGRATION_PLAN.md) - Detailed migration plan and timeline
- [FLUTTER_TO_REACT_NATIVE.md](FLUTTER_TO_REACT_NATIVE.md) - Guide for translating Flutter concepts to React Native
- [DEPENDENCIES.md](DEPENDENCIES.md) - List of React Native dependencies
- [GAME_LOGIC.md](GAME_LOGIC.md) - Implementation of the game logic
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Firebase integration guide
- [SAMPLE_COMPONENTS.md](SAMPLE_COMPONENTS.md) - Sample React Native component implementations

## References

* [ECCO](https://www.xqbase.com/ecco/ecco_contents.htm#ecco_a)
* [UCCI](https://www.xqbase.com/protocol/cchess_ucci.htm)
* [Move Notation](https://www.xqbase.com/protocol/cchess_move.htm)
* [FEN Format](https://www.xqbase.com/protocol/cchess_fen.htm)
* [PGN Format](https://www.xqbase.com/protocol/cchess_pgn.htm)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

* Original Flutter implementation by [Original Author]
* React Native migration by [Your Name]
* Chess engine based on [xqlite](https://github.com/xqbase/xqwlight)
* UI design inspired by "Chinese Chess Wizard" (象棋小巫师)
