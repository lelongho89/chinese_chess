# Product Requirements Document (PRD) for Xiangqi Mobile App MVP

## Product Summary

### Brief Description
The Xiangqi mobile app MVP delivers a core Chinese Chess experience on iOS and Android, focusing on single-player and local multiplayer modes. It ensures adherence to standard Chinese Chess rules while providing a user-friendly interface for both beginners and experienced players. The MVP prioritizes essential gameplay mechanics and minimal user features to enable a quick launch while laying the foundation for future expansions.

### Target Audience
- **Casual gamers**: Users seeking quick, engaging strategy games during breaks.
- **Fans of traditional Chinese culture**: Individuals interested in playing Xiangqi on the go.
- **Chess enthusiasts**: Players looking for a new challenge beyond Western chess.

### Key Features
- **Game Board and Piece Movement**: A 9x10 grid with standard pieces and movements.
- **Single-Player Mode**: Play against a basic AI with one difficulty level.
- **Local Multiplayer**: Pass-and-play for two players on the same device.
- **Basic Game Mechanics**: Move validation, game state management, and simple timer.
- **User Features**: Guest play, optional registration, basic profiles, and minimal customization.

### Value Proposition
The app provides an accessible and authentic Chinese Chess experience, allowing users to enjoy the game anytime, anywhere, with the convenience of mobile devices.

## Personas

### Persona 1: Casual Gamer
- **Name**: Li Wei
- **Age**: 25-35
- **Occupation**: Office worker
- **Interests**: Mobile games, strategy games
- **Needs**: Quick, engaging gameplay during breaks.
- **Pain Points**: Limited time for gaming; wants easy-to-learn but deep gameplay.

### Persona 2: Traditionalist
- **Name**: Zhang Mei
- **Age**: 40-55
- **Occupation**: Business owner
- **Interests**: Chinese culture, board games
- **Needs**: A way to play Xiangqi on the go.
- **Pain Points**: Physical board games are not always convenient.

## User Stories
1. **As a casual gamer**, I want to play a quick game of Xiangqi during my lunch break to relax and have fun.
2. **As a traditionalist**, I want to play Xiangqi with my friends who are nearby to share our love for the game.
3. **As a beginner**, I want to learn the basic rules of Xiangqi through simple gameplay to start playing quickly.

## Project Timeline

### Phase 1: Planning and Design (1 month)
- Define MVP requirements based on core features.
- Design UI/UX for the game board, single-player, and local multiplayer modes.
- Finalize game mechanics for MVP.

### Phase 2: Development (3 months)
- Develop game board, piece movements, and game logic.
- Implement single-player mode with basic AI.
- Add local multiplayer mode with a simple timer.
- Integrate basic user features (guest play, registration, profiles, customization).

### Phase 3: Testing (1 month)
- Conduct unit testing for game logic and features.
- Perform integration testing across iOS and Android.
- Run user acceptance testing with beta users.

### Phase 4: Launch (1 month)
- Prepare app store listings and screenshots.
- Submit apps to Apple App Store and Google Play Store.
- Monitor initial user feedback for post-launch improvements.

**Total Estimated Time**: 6 months

## Constraints
- Must support iOS and Android devices.
- Single-player mode must work offline.
- Local multiplayer requires no internet.
- Must comply with Apple App Store and Google Play Store guidelines.
- Budget constraints require prioritizing essential features over advanced ones.

## Detailed Features for MVP

### Feature 1: Game Board and Piece Movement
- **What the User Sees**:
  - A 9x10 grid board with pieces placed on intersections.
  - Pieces labeled with Chinese characters or icons.
  - Highlighted possible moves when a piece is selected.
  - Visual indicators for game states (e.g., red glow for check, pop-up for checkmate).
  - "River" and "Palace" visually distinguished.
- **Data/Input Collected**:
  - User touches on the board to select pieces and destinations.
  - Game state, including piece positions, turn order, and captured pieces.
- **Conditions for Success**:
  - Pieces move according to standard Xiangqi rules.
  - Special rules enforced (e.g., "flying general," river crossing for Soldiers).
  - UI prevents illegal moves with clear feedback.
  - Game accurately detects check, checkmate, stalemate, and draws.

### Feature 2: Single-Player Mode
- **What the User Sees**:
  - Menu to select AI difficulty (one level: Easy).
  - Game starts with AI as the opponent, displaying moves in real-time.
  - Options to undo moves or restart the game.
- **Data/Input Collected**:
  - User's selected difficulty level.
  - User's moves during the game.
- **Conditions for Success**:
  - AI provides a fair challenge at the selected difficulty.
  - AI adheres to Xiangqi rules and does not make illegal moves.
  - Game ends correctly with win, loss, or draw based on user performance.

### Feature 3: Local Multiplayer
- **What the User Sees**:
  - Option to play locally with another player (hotseat).
  - Turn indicator showing whose turn it is.
  - Basic timer (e.g., 5 minutes per player).
- **Data/Input Collected**:
  - Moves made by each player.
- **Conditions for Success**:
  - Turns alternate seamlessly between players.
  - Timer functions correctly and ends the game when time runs out.

### Feature 4: Basic Game Mechanics
- **What the User Sees**:
  - Move history displayed (optional for MVP).
  - Current turn indicator.
  - Notifications for game end conditions (checkmate, stalemate, draw).
- **Data/Input Collected**:
  - All moves made during the game.
- **Conditions for Success**:
  - Game state is accurately tracked (turns, end conditions).
  - Move history is recorded for reference.

### Feature 5: User Features
- **What the User Sees**:
  - Option to play as a guest or register with email/password.
  - Basic profile with username and simple statistics (wins, losses, draws).
  - Default board theme and piece set.
  - Basic sound settings (move and capture sounds).
- **Data/Input Collected**:
  - User registration details (if registered).
  - Game outcomes for statistics.
- **Conditions for Success**:
  - Users can play without registration (guest mode).
  - Registered users' data is saved across sessions.
  - Customization options (theme, sounds) work as expected.

## User Acceptance Criteria (UAC)
- All pieces move correctly according to Xiangqi rules.
- Single-player AI provides a fair challenge.
- Local multiplayer allows seamless turn-based play.
- Game states (check, checkmate, stalemate, draw) are accurately detected.
- Users can play single-player mode offline.
- App works on both iOS and Android with no major bugs.

## Final Notes
This PRD focuses on delivering an MVP that captures the essence of Xiangqi, providing a solid foundation for future expansions. The development team should prioritize these core features to ensure a timely and successful launch.