# Firebase Configuration Files

This directory contains the Firebase configuration files for iOS and Android platforms.

## Setup Instructions

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "Chinese Chess")
4. Configure Google Analytics (optional but recommended)
5. Click "Create project"

### 2. Register Your App with Firebase

#### For Android:

1. In the Firebase console, click the Android icon
2. Enter your app's package name (e.g., `com.chinesechessrn`)
3. Enter a nickname (optional)
4. Enter your SHA-1 key (for Google Sign-In)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the file in your project's `android/app` directory

#### For iOS:

1. In the Firebase console, click the iOS icon
2. Enter your app's Bundle ID (e.g., `com.chinesechessrn`)
3. Enter a nickname (optional)
4. Enter your App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Place the file in your project's `ios/ChineseChessRN` directory
8. Open your project in Xcode and add the file to your project

### 3. Update Firebase Configuration

Update the Firebase configuration in `src/services/firebase/config.ts` with your project's values:

```typescript
export const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};
```

### 4. Configure Build Files

#### Android Configuration:

1. Modify `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    // Add this line
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

2. Modify `android/app/build.gradle`:

```gradle
apply plugin: 'com.android.application'
// Add this line
apply plugin: 'com.google.gms.google-services'

dependencies {
  // Add these lines if not automatically added
  implementation platform('com.google.firebase:firebase-bom:32.7.0')
  implementation 'com.google.firebase:firebase-analytics'
}
```

#### iOS Configuration:

1. Install pods:

```bash
cd ios
pod install
cd ..
```

## Security Rules

### Firestore Rules

Create security rules for your Firestore database in the Firebase Console:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own profile
    match /users/{userId} {
      allow read: if request.auth != null && (request.auth.uid == userId || isAdmin());
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Games can be read by participants and created/updated by participants
    match /games/{gameId} {
      allow read: if request.auth != null && (
        resource.data.players.hasAny([request.auth.uid]) || isAdmin()
      );
      allow create: if request.auth != null;
      allow update: if request.auth != null && (
        resource.data.players.hasAny([request.auth.uid]) || isAdmin()
      );
      allow delete: if isAdmin();
    }
    
    // User settings can be read/written by the user
    match /userSettings/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Tournaments can be read by anyone, created/updated by admins
    match /tournaments/{tournamentId} {
      allow read: if request.auth != null;
      allow create, update, delete: if isAdmin();
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
  }
}
```

### Storage Rules

Create security rules for your Storage in the Firebase Console:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Game assets can be read by anyone
    match /assets/{assetId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can upload via Firebase console
    }
  }
}
```
