# Enhanced Anonymous Authentication System

## Overview

The anonymous authentication system has been enhanced with device ID-based persistence and profile deletion functionality. This allows users to maintain their stats across app sessions while providing the option to start fresh when desired.

## Key Features

### 1. Device ID-Based Persistence
- **Unique Device Identification**: Each device gets a unique identifier that persists across app installations
- **Stats Preservation**: User stats, Elo rating, and game history are preserved when the user returns
- **Cross-Session Continuity**: Anonymous users maintain their identity across app restarts

### 2. Profile Deletion
- **Complete Data Removal**: Anonymous users can delete their profile and all associated data
- **Fresh Start**: After deletion, the next login creates a completely new profile
- **Confirmation Dialog**: Users must confirm before deletion to prevent accidental data loss

## Technical Implementation

### Device ID Service (`lib/services/device_id_service.dart`)
- Generates unique device identifiers using platform-specific APIs
- **Android**: Uses Android ID combined with UUID for uniqueness
- **iOS**: Uses identifierForVendor combined with UUID
- **Fallback**: Pure UUID for unsupported platforms
- Stores device ID locally using SharedPreferences

### Enhanced User Model
- Added `deviceId` field to track device association
- Updated constructors and serialization methods
- Maintains backward compatibility with existing data

### Database Schema Updates
- Added `device_id` column to users table
- Created indexes for efficient device-based lookups
- Updated RLS policies for device-based access
- Migration script: `supabase/migrations/20240103000000_add_device_id_column.sql`

### Authentication Flow

#### First-Time Anonymous Login
1. Generate unique device ID
2. Create Supabase anonymous session
3. Store user data with device ID in database
4. Generate random display name (e.g., "SwiftMaster1234")

#### Returning User Login
1. Retrieve stored device ID
2. Check for existing user with same device ID
3. If found: Link new session to existing user data
4. If not found: Create new user (handles device ID changes)

#### Profile Deletion
1. Verify user is anonymous
2. Delete all user data from database
3. Clear device ID from local storage
4. Sign out from Supabase
5. Next login creates fresh profile

## User Experience

### Anonymous User Journey
1. **First Visit**: Tap "Continue as Guest" → Instant access with random name
2. **Return Visits**: Automatic login with preserved stats and progress
3. **Fresh Start**: Option to delete profile and start over

### Profile Management
- Anonymous users see "Delete Profile" option in settings
- Clear warning about permanent data loss
- Confirmation dialog prevents accidental deletion
- Immediate feedback on successful deletion

## Code Changes Summary

### New Files
- `lib/services/device_id_service.dart` - Device ID management
- `supabase/migrations/20240103000000_add_device_id_column.sql` - Database migration

### Modified Files
- `pubspec.yaml` - Added device_info_plus dependency
- `lib/models/user_model.dart` - Added deviceId field
- `lib/models/supabase_auth_service.dart` - Enhanced anonymous login and deletion
- `lib/models/user_repository.dart` - Device-based user operations
- `lib/screens/profile_screen.dart` - Profile deletion UI
- `lib/main.dart` - Initialize device ID service

### New Methods
- `DeviceIdService.getDeviceId()` - Get/generate device identifier
- `DeviceIdService.clearDeviceId()` - Clear stored device ID
- `UserRepository.getUserByDeviceId()` - Find user by device
- `UserRepository.createAnonymousUserWithDevice()` - Create user with device ID
- `UserRepository.linkDeviceToUser()` - Link session to existing data
- `UserRepository.deleteAnonymousUserData()` - Complete data deletion
- `SupabaseAuthService.deleteAnonymousProfile()` - Profile deletion flow

## Benefits

### For Users
- **Seamless Experience**: No registration required, stats preserved
- **Privacy**: No personal information collected
- **Control**: Can delete data and start fresh anytime
- **Reliability**: Works across app updates and reinstalls

### For Developers
- **User Retention**: Stats preservation encourages continued play
- **Data Integrity**: Device-based tracking prevents duplicate accounts
- **Compliance**: Easy data deletion for privacy requirements
- **Scalability**: Efficient database queries with proper indexing

## Security Considerations

- Device IDs are not personally identifiable
- RLS policies restrict access to user's own data
- Profile deletion is irreversible (by design)
- Device ID changes are handled gracefully

## Future Enhancements

- Option to backup/restore profile via QR code
- Merge profiles when converting to permanent account
- Analytics on anonymous user behavior patterns
- Enhanced device fingerprinting for better persistence

## Testing Recommendations

1. Test device ID generation on different platforms
2. Verify stats persistence across app restarts
3. Test profile deletion and fresh start flow
4. Validate database migration on existing data
5. Test edge cases (device ID changes, network issues)
