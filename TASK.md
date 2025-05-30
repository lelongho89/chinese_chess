# Chinese Chess - MVP Task Management (Flutter-Based)

## Current Tasks
| Task ID | Description | Assignee | Status | Priority | Estimated Time | Phase |
|---------|-------------|----------|--------|----------|----------------|-------|
| T1-001  | Integrate Firebase Authentication for email/password registration | Frontend Team | Completed | High | 1 week | Phase 1 |
| T1-002  | Set up Firebase Firestore for user data storage | Backend Team | Completed | High | 0.5 weeks | Phase 1 |
| T1-003  | Adapt existing Flutter game logic for server-side validation | Backend/Frontend Team | Not Started | High | 1 week | Phase 1 |
| T1-004  | Update existing Flutter chess board for default skin | Frontend Team | Completed | Medium | 0.5 weeks | Phase 1 |
| T1-005  | Implement blitz timer (3+2) in Flutter | Frontend Team | Completed | High | 1 week | Phase 1 |
| T1-010  | Migrate from Firebase to Supabase | Backend/Frontend Team | Completed | High | 1 week | Phase 1 |
| T1-011  | Implement QR code sharing for match invitations | Frontend Team | Completed | Medium | 0.5 weeks | Phase 1 |
| T1-012  | Implement Robot Player AI for Online Matchmaking | Frontend/Backend Team | Completed | High | 1 week | Phase 1 |
| T1-013  | Implement Side Alternation for Fair Online Matches | Frontend/Backend Team | Completed | High | 0.5 weeks | Phase 1 |
| T1-014  | Simplify Matchmaking with Single Time Control | Frontend/Backend Team | Completed | Medium | 0.5 weeks | Phase 1 |
| T1-015  | Fix Database Schema Compatibility and AI Matching | Frontend/Backend Team | Completed | High | 0.5 weeks | Phase 1 |

### T1-011: Implement QR code sharing for match invitations (Completed)
- ✅ Create database schema for match invitations
- ✅ Implement match invitation model and repository
- ✅ Add QR code generation and scanning functionality
- ✅ Create UI for sharing and scanning QR codes
- ✅ Implement match joining via QR code
- ✅ Test QR code sharing on iOS and Android

## Backlog
### Phase 1
- **T1-006**: Set up WebSocket integration with `web_socket_channel` for game sync — Frontend/Backend Team, 1 week, High
- **T1-007**: Audit existing Flutter codebase for compatibility — Frontend Team, 0.5 weeks, High
- **T1-008**: Set up GitHub Actions for Flutter CI/CD — DevOps Team, 0.5 weeks, Medium
- **T1-009**: Design login/registration UI in Flutter — Design Team, 0.5 weeks, Medium

### Phase 2
- **T2-001**: Implement basic Elo rating (K=32) — Backend Team, 1 week, High
- **T2-002**: Develop matchmaking queue with Elo proximity — Backend Team, 1 week, High
- **T2-003**: Add game history storage and Flutter UI — Backend/Frontend Team, 1 week, Medium
- **T2-004**: Implement server-side anti-cheating validation — Backend Team, 0.5 weeks, Medium

### Phase 3
- **T3-001**: Create single elimination tournament service — Backend Team, 1 week, High
- **T3-002**: Build tournament bracket UI in Flutter — Frontend Team, 1 week, High
- **T3-003**: Optimize WebSocket and Flutter performance — Frontend/Backend Team, 0.5 weeks, Medium
- **T3-004**: Conduct E2E testing with Flutter `integration_test` — QA Team, 0.5 weeks, High

## Sub-Tasks
### T1-001: Integrate Firebase Authentication for email/password registration
- ✅ Add Firebase SDK to Flutter project
- ✅ Create Flutter login/registration screens
- ✅ Implement email verification flow
- Test with 50 concurrent users

### T1-002: Set up Firebase Firestore for user data storage (Completed)
- ✅ Define Firestore data models
- ✅ Set up Firestore collections and documents
- ✅ Implement Firestore repositories
- ✅ Set up Firestore security rules
- ✅ Create service classes for Firestore operations
- ✅ Add caching for offline support
- ✅ Test Firestore integration

### T1-004: Update existing Flutter chess board for default skin (Completed)
- ✅ Review existing board widget in Flutter
- ✅ Update assets for wooden board and classic pieces
- ✅ Ensure assets are optimized for iOS, Android, and web
- ✅ Test rendering performance

### T1-005: Implement blitz timer (3+2) in Flutter (Completed)
- ✅ Create Flutter timer widget with countdown
- ✅ Add color-coded low-time warning
- ✅ Sync with server via WebSocket
- ✅ Test timer accuracy across platforms

### T1-010: Migrate from Firebase to Supabase (Completed)
- ✅ Add Supabase dependencies to Flutter project
- ✅ Create Supabase database schema
- ✅ Implement Supabase authentication service
- ✅ Update repositories to use Supabase
- ✅ Update UI components to work with Supabase
- ✅ Set up Supabase Realtime for real-time updates
- ✅ Test Supabase integration

### T1-012: Implement Robot Player AI for Online Matchmaking (Completed)
- ✅ Create enhanced DriverRobotOnline class for online AI players
- ✅ Integrate robot players with online game synchronization
- ✅ Modify matchmaking system to spawn robot players after timeout
- ✅ Update UI to display "Bot" labels for AI opponents
- ✅ Implement move synchronization between robot AI and server
- ✅ Add difficulty scaling based on human player Elo rating
- ✅ Test robot player behavior in online matches
- ✅ Ensure robot moves are properly validated and synchronized

### T1-013: Implement Side Alternation for Fair Online Matches (Completed)
- ✅ Add side tracking fields to user model (lastPlayedSide, redGamesPlayed, blackGamesPlayed)
- ✅ Create SideAlternationService for managing fair side assignment
- ✅ Update matchmaking service to use side alternation logic
- ✅ Implement alternation for both human vs human and human vs AI matches
- ✅ Add database migration for side tracking fields
- ✅ Update game service to track side history after games
- ✅ Create comprehensive unit tests for side alternation logic
- ✅ Add database functions for side statistics and history management

### T1-014: Simplify Matchmaking with Single Time Control (Completed)
- ✅ Create AppConfig class for centralized configuration management
- ✅ Remove side preference selection from matchmaking UI
- ✅ Remove time control selection from matchmaking UI
- ✅ Update matchmaking queue model to remove preferred_color field
- ✅ Update matchmaking service to use AppConfig for time control
- ✅ Update side alternation service to work without preferences
- ✅ Create database migration to remove preferred_color column
- ✅ Update matchmaking screen with simplified UI showing fixed time control
- ✅ Create comprehensive unit tests for simplified matchmaking
- ✅ Add environment variable support for configuration switching

### T1-015: Fix Database Schema Compatibility and AI Matching (Completed)
- ✅ Fix preferred_color column mismatch between model and database schema
- ✅ Resolve RLS policy violations for AI user queue insertion
- ✅ Update AI matching to find opponents directly from users table
- ✅ Eliminate dependency on AI users being in matchmaking queue
- ✅ Add backward compatibility for legacy database schemas
- ✅ Improve error handling and debugging for matchmaking process
- ✅ Reduce AI matching wait time to 5 seconds for faster testing
- ✅ Add force AI matching method for immediate testing
- ✅ Fix Online Multiplayer button initialization issue
- ✅ Fix quit game navigation to return to main screen

## Notes
- Assume existing Flutter code handles basic Chinese Chess gameplay; tasks focus on online integration.
- Prioritize tasks to enable end-to-end gameplay first.
- Bi-weekly sprint reviews to adjust priorities.
- Use Jira for task tracking and status updates.
- Ensure code reviews for all changes to existing Flutter codebase.
- Test on iOS, Android, and web to ensure cross-platform consistency.