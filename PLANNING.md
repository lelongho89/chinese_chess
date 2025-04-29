# Chinese Chess - MVP Development Planning (Flutter-Based)

## Vision
Build a functional online Chinese Chess MVP using an existing Flutter codebase, enabling players to register, play ranked matches, and participate in basic tournaments. The MVP will validate online gameplay, user engagement, and matchmaking, leveraging Flutter’s cross-platform capabilities for a consistent experience on iOS, Android.

## Goals
- Launch the MVP within 10 weeks, extending the existing Flutter codebase.
- Deliver core features: user accounts, ranked matches, blitz timer, and single elimination tournaments.
- Ensure low-latency gameplay and reliable matchmaking.
- Collect user feedback for future iterations.
- Maintain a modular architecture for scalability and future enhancements.

## Technical Architecture

### Overview
The MVP will extend the existing Flutter frontend for cross-platform support, integrating with a backend for online features. The backend will use a microservices architecture with WebSockets for real-time game synchronization and a cloud-based database for user data. The existing Flutter code is assumed to include basic game logic (board rendering, move validation), which will be adapted for online play.

### Components
1. **Frontend (Flutter)**
   - Framework: Flutter with Dart for cross-platform UI (iOS, Android, web).
   - Styling: Material Design for consistent, responsive UI; custom widgets for chess board and pieces.
   - Dependencies: Firebase SDK for authentication and Firestore, WebSocket package (e.g., `web_socket_channel`) for real-time sync.
   - Features: Login/registration, game board, blitz timer, and basic tournament UI.

2. **Backend**
   - Language: Node.js with Express for REST APIs.
   - Real-time: WebSocket server (Socket.IO) for game state synchronization.
   - Authentication: Firebase Authentication for email/password login.
   - Anti-cheating: Basic server-side validation for moves and timers.

3. **Database**
   - Primary: Firebase Firestore for user data, ratings, and game history.
   - Asset Storage: Firebase Storage for default skin assets.

4. **Game Logic**
   - Core: Reuse existing Flutter-based move validation logic, with server-side verification.
   - Rating: Simplified Elo algorithm with fixed K-factor (e.g., K=32).
   - Time Control: Server-synchronized blitz timer (3+2 format).

5. **Tournament System**
   - Microservice: Basic service for single elimination tournaments.
   - Format: Simple bracket with manual seeding.

### Constraints
- **Performance**: Matchmaking wait time < 20 seconds, timer accuracy within 100ms.
- **Scalability**: Handle 500 concurrent users.
- **Privacy**: Basic GDPR compliance with secure data handling and user consent.
- **Cross-Platform**: Ensure consistent experience on iOS, Android, and web using Flutter.
- **Existing Code**: Adapt existing Flutter codebase, addressing any technical debt or limitations.
- **Scope**: Exclude social logins, leaderboards, custom skins, and advanced tournament formats.

## Tech Stack
- **Frontend**: Flutter, Dart, Material Design, Firebase SDK, `web_socket_channel`.
- **Backend**: Node.js, Express, Socket.IO, Firebase Authentication.
- **Database**: Firebase Firestore, Firebase Storage.
- **DevOps**: GitHub Actions for CI/CD, Flutter’s build tools for platform-specific outputs.
- **Testing**: Flutter’s `test` package for unit tests, `integration_test` for E2E tests.
- **Monitoring**: Firebase Analytics for basic usage tracking.

## Tools
- **Version Control**: Git with GitHub.
- **Project Management**: Jira for task tracking.
- **Design**: Figma for UI updates to existing Flutter widgets.
- **Communication**: Slack for team collaboration.
- **IDE**: VS Code or Android Studio for Flutter development.

## Development Phases
1. **Phase 1 (4 weeks)**: Integrate user registration, adapt existing game logic for online play, implement default skin, and add blitz timer.
2. **Phase 2 (3 weeks)**: Add basic Elo rating, matchmaking, and game history.
3. **Phase 3 (3 weeks)**: Implement single elimination tournament mode and optimize performance.

## Risks and Mitigation
- **Risk**: Incompatibilities in existing Flutter codebase (e.g., outdated dependencies).
  - **Mitigation**: Audit codebase, update dependencies, and refactor critical components.
- **Risk**: Performance issues on web platform.
  - **Mitigation**: Optimize WebSocket payloads and test thoroughly with Flutter web.
- **Risk**: Cheating in ranked games.
  - **Mitigation**: Implement server-side move and timer validation.
- **Risk**: Scope creep from adding non-MVP features.
  - **Mitigation**: Define strict MVP scope and prioritize core functionality.

## Success Metrics
- 50% of testers create accounts within the first week.
- Average session time of 10 minutes.
- 80% of matches rated as "fair" by players.
- 90% of tournaments complete without technical issues.
- Consistent performance across iOS, Android, and web.