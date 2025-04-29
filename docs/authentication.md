# Chinese Chess Authentication System

## Overview

The Chinese Chess game uses Firebase Authentication for user registration and login. The authentication system supports:

1. Email/password registration and login
2. Google sign-in
3. Facebook sign-in
4. Email verification
5. Password reset
6. Account linking
7. User profile management

## Architecture

The authentication system is built using the following components:

1. **AuthService**: A singleton service that handles all Firebase Authentication operations
2. **UserModel**: A model class for storing user data
3. **UserRepository**: A repository for handling user data in Firestore
4. **Authentication Screens**: UI components for login, registration, password reset, and email verification

## Authentication Flow

1. **Registration**:
   - User enters email, password, and display name
   - Firebase creates a new user account
   - Verification email is sent to the user
   - User data is stored in Firestore

2. **Email Verification**:
   - User receives a verification email with a link
   - User clicks the link to verify their email
   - User can request a new verification email if needed

3. **Login**:
   - User enters email and password
   - Firebase authenticates the user
   - If email is not verified, user is prompted to verify
   - If email is verified, user is logged in

4. **Password Reset**:
   - User enters email address
   - Firebase sends a password reset link
   - User clicks the link to reset their password

## User Data

User data is stored in Firestore with the following structure:

```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "User Name",
  "eloRating": 1200,
  "gamesPlayed": 0,
  "gamesWon": 0,
  "gamesLost": 0,
  "gamesDraw": 0,
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

## Security Rules

Firestore security rules should be configured to:

1. Allow users to read and write only their own data
2. Prevent unauthorized access to other users' data
3. Validate data before writing to the database

## Implementation Details

### AuthService

The `AuthService` class is a singleton that provides methods for:

- Signing in with email and password
- Signing in with Google
- Signing in with Facebook
- Registering with email and password
- Sending email verification
- Resetting password
- Signing out
- Updating user profile
- Linking accounts (Google, Facebook)
- Unlinking accounts
- Getting linked providers

### UserRepository

The `UserRepository` class provides methods for:

- Creating a new user in Firestore
- Getting user data from Firestore
- Updating user data in Firestore
- Deleting user data from Firestore

### Authentication Screens

The authentication screens include:

- Login screen (with email/password, Google, and Facebook login options)
- Registration screen (with email/password, Google, and Facebook registration options)
- Forgot password screen
- Email verification screen
- Social login buttons widget (reusable component for Google and Facebook login)

## Testing

The authentication system should be tested with:

1. Unit tests for AuthService and UserRepository
2. Widget tests for authentication screens
3. Integration tests for the complete authentication flow
4. Stress tests with multiple concurrent users

## Social Login Configuration

### Google Sign-In

To configure Google Sign-In:

1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the Google Sign-In API
3. Configure the OAuth consent screen
4. Create OAuth 2.0 client IDs for Android and iOS
5. Add the SHA-1 fingerprint of your Android app to the Firebase project
6. Update the Android configuration:
   - No additional configuration needed beyond Firebase setup
7. Update the iOS configuration:
   - Add the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` to `Info.plist`

### Facebook Sign-In

To configure Facebook Sign-In:

1. Create an app in the [Facebook Developer Console](https://developers.facebook.com/)
2. Add the Facebook Login product to your app
3. Configure the OAuth redirect URI
4. Update the Android configuration:
   - Add the Facebook App ID and Client Token to `strings.xml`
   - Add the Facebook activity to `AndroidManifest.xml`
5. Update the iOS configuration:
   - Add the Facebook App ID, Client Token, and URL schemes to `Info.plist`
6. Add the Facebook App ID and Client Token to your Firebase project

## Future Enhancements

Potential future enhancements include:

1. Additional social login providers (Apple, Twitter, GitHub, etc.)
2. Two-factor authentication
3. Phone number authentication
4. Anonymous authentication with account upgrade
5. Admin panel for user management
