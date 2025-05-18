# Chinese Chess Business Logic Documentation

## Overview

This document outlines the business logic and features of the Chinese Chess (Xiangqi) application. It serves as a comprehensive guide for understanding the game mechanics, user interactions, and application features to facilitate the creation of a new project from scratch.

## Game Rules

### Board Layout
- 9×10 grid board
- Two sides: Red (traditionally at bottom) and Black (traditionally at top)
- The board includes a "river" in the middle and two "palaces" at each end

### Pieces and Movement
1. **General/King (将/帅)**
   - Moves one step orthogonally (horizontally or vertically)
   - Confined to the palace (3×3 grid)
   - Cannot face the opposing General directly with no pieces in between ("flying general" rule)

2. **Advisor/Guard (士/仕)**
   - Moves one step diagonally
   - Confined to the palace (3×3 grid)

3. **Elephant/Minister (象/相)**
   - Moves exactly two points diagonally
   - Cannot cross the river
   - Cannot jump over intervening pieces ("elephant's eye" rule)

4. **Horse/Knight (马/馬)**
   - Moves one point orthogonally followed by one point diagonally outward
   - Cannot jump over intervening pieces ("horse's leg" rule)

5. **Chariot/Rook (车/車)**
   - Moves any distance orthogonally
   - Cannot jump over intervening pieces

6. **Cannon (炮/砲)**
   - Moves like the Chariot when not capturing
   - To capture, must jump over exactly one piece (of either color)

7. **Soldier/Pawn (兵/卒)**
   - Moves one point forward before crossing the river
   - After crossing the river, can move one point forward or horizontally
   - Cannot move backward

### Game Conditions
- **Check**: When a General is under threat of capture
- **Checkmate**: When a General is in check and cannot escape
- **Stalemate**: When a player has no legal moves but is not in check
- **Perpetual Check**: Repeatedly putting the opponent in check with the same sequence of moves
- **Draw**: Declared after 60 moves without a capture or pawn advancement

## Core Game Features

### Game Modes
1. **Single Player (vs AI)**
   - Multiple AI difficulty levels
   - AI thinking time indicators
   - Adjustable AI strength

2. **Local Multiplayer**
   - Pass-and-play on the same device
   - Timer options for competitive play

3. **Online Multiplayer**
   - Matchmaking with players of similar skill
   - Ranked and casual games
   - Tournament support

### Game Mechanics
1. **Move Validation**
   - Enforce all Chinese Chess rules
   - Highlight legal moves for selected pieces
   - Prevent illegal moves (e.g., moving into check)

2. **Game State Management**
   - Track current player's turn
   - Record move history
   - Support for FEN notation (standard chess position notation)
   - Detect game end conditions (checkmate, stalemate, draw)

3. **Timer System**
   - Configurable time controls (e.g., 5+3, 10+5)
   - Time increment after moves
   - Time penalty for illegal move attempts

4. **Move History and Notation**
   - Record and display move history
   - Support for standard Chinese Chess notation
   - Move replay functionality

## User Features

### Authentication
1. **User Accounts**
   - Email/password registration and login
   - Social login (Google, Facebook)
   - Guest play option

2. **User Profiles**
   - Customizable usernames and avatars
   - Statistics tracking (wins, losses, draws)
   - Rating system (Elo or similar)

### Customization
1. **Board and Piece Themes**
   - Multiple visual themes (traditional, modern)
   - Custom piece sets (woods, stones)
   - Board color and texture options

2. **Sound Settings**
   - Move sounds
   - Capture sounds
   - Check/checkmate notification sounds
   - Background music options

3. **Language Options**
   - Multi-language support
   - Localized UI and game terminology

### Game History and Analysis
1. **Game Recording**
   - Save completed games
   - Export games in standard notation
   - Share games with others

2. **Game Replay**
   - Step-by-step replay of past games
   - Adjustable replay speed
   - Analysis mode with move suggestions

3. **Statistics and Analytics**
   - Win/loss records
   - Performance against different opponents
   - Improvement tracking over time

## Social Features

### Friends and Community
1. **Friends System**
   - Add and manage friends
   - See online status
   - Challenge friends to games

2. **Leaderboards**
   - Global rankings
   - Friend rankings
   - Tournament standings

3. **Achievements**
   - Skill-based achievements
   - Progression achievements
   - Special accomplishments

### Communication
1. **In-Game Chat**
   - Chat with opponents during games
   - Predefined messages for quick communication
   - Emoji support

2. **Notifications**
   - Game invites
   - Turn notifications
   - Friend activity updates

## Premium Features

### Enhanced Learning
1. **Tutorials**
   - Interactive lessons on piece movement
   - Strategy guides
   - Famous game studies

2. **Puzzle Mode**
   - Daily puzzles
   - Difficulty progression
   - Timed challenges

### Advanced Analysis
1. **Engine Analysis**
   - Deep position evaluation
   - Move suggestion with explanations
   - Mistake identification

2. **Opening Library**
   - Standard opening sequences
   - Opening statistics
   - Personalized recommendations

## Technical Requirements

1. **Performance**
   - Smooth animations
   - Responsive UI
   - Low latency for online play

2. **Offline Support**
   - Play vs AI without internet
   - Cached game history
   - Synchronization when back online

3. **Cross-Platform**
   - Consistent experience across devices
   - State preservation between sessions
   - Adaptive layouts for different screen sizes
