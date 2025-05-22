# Chinese Chess (Xiangqi)

A modern implementation of the traditional Chinese Chess (Xiangqi) game built with Flutter.

*** Important Note: This project is for learning and research purposes only. The images and sound resources are from "Chinese Chess Wizard" (象棋小巫师), and the built-in engine is translated from xqlite (JS). Please do not use these resources for commercial projects. ***

## Platforms
- [x] Android
- [x] iOS

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for deployment

### Installation

1. Clone this repository
```bash
git clone https://github.com/yourusername/chinese_chess.git
```

2. Navigate to the project directory
```bash
cd chinese_chess
```

3. Install dependencies
```bash
flutter pub get
```

4. Set up environment variables
Create a `.env` file in the root directory with your Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

5. Generate localization files
```bash
flutter gen-l10n
```

6. Run the app
```bash
flutter run
```

## Features

### Authentication
- **Anonymous Authentication**: Users can start playing immediately without registration
- **Email/Password Authentication**: Traditional registration and login
- **Social Authentication**: Google and Facebook sign-in
- **Account Conversion**: Anonymous users can convert to permanent accounts

### Game Modes
- **Robot Mode**: Play against AI with adjustable difficulty levels
- **Free Mode**: Practice mode for studying positions
- **Online Mode**: Multiplayer functionality (coming soon)

### User Features
- **Profile Management**: Update display names and view statistics
- **Guest Mode**: Play without creating an account
- **Progress Tracking**: Game statistics and Elo ratings
- **Customization**: Board themes and sound settings

## References
* [ECCO](https://www.xqbase.com/ecco/ecco_contents.htm#ecco_a)
* [UCCI](https://www.xqbase.com/protocol/cchess_ucci.htm)
* [Move Notation](https://www.xqbase.com/protocol/cchess_move.htm)
* [FEN Format](https://www.xqbase.com/protocol/cchess_fen.htm)
* [PGN Format](https://www.xqbase.com/protocol/cchess_pgn.htm)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for more information.

## License

This project is licensed under the MIT License.