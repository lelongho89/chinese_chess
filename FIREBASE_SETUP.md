# Firebase Setup for React Native Chinese Chess

This document outlines the steps to set up Firebase for the React Native implementation of the Chinese Chess application.

## Prerequisites

Before setting up Firebase, ensure you have:

1. A Firebase account
2. React Native project initialized
3. React Native Firebase dependencies installed

## Installation

### 1. Install Required Dependencies

```bash
# Install core Firebase package
npm install @react-native-firebase/app

# Install Firebase services
npm install @react-native-firebase/auth
npm install @react-native-firebase/firestore
npm install @react-native-firebase/storage
npm install @react-native-firebase/analytics
```

### 2. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "Chinese Chess")
4. Configure Google Analytics (optional but recommended)
5. Click "Create project"

### 3. Register Your App with Firebase

#### For Android:

1. In the Firebase console, click the Android icon
2. Enter your app's package name (e.g., `com.yourcompany.chinesechess`)
3. Enter a nickname (optional)
4. Enter your SHA-1 key (for Google Sign-In)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the file in your project's `android/app` directory

#### For iOS:

1. In the Firebase console, click the iOS icon
2. Enter your app's Bundle ID (e.g., `com.yourcompany.chinesechess`)
3. Enter a nickname (optional)
4. Enter your App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Place the file in your project's `ios/YourApp` directory
8. Open your project in Xcode and add the file to your project

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

### 5. Initialize Firebase in Your App

Create a file `src/services/firebase/index.js`:

```javascript
import { Platform } from 'react-native';
import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import storage from '@react-native-firebase/storage';
import analytics from '@react-native-firebase/analytics';

// Your Firebase configuration
const firebaseConfig = {
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};

// Initialize Firebase if it hasn't been initialized yet
if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

// Enable Firestore offline persistence
firestore().settings({
  persistence: true,
});

// Configure Analytics
if (Platform.OS !== 'web') {
  analytics().setAnalyticsCollectionEnabled(true);
}

export { firebase, auth, firestore, storage, analytics };
```

Replace the placeholder values in `firebaseConfig` with your actual Firebase project configuration.

## Firebase Services Setup

### Authentication Service

Create a file `src/services/firebase/authService.js`:

```javascript
import { auth, firestore } from './index';

class AuthService {
  // Get the current user
  getCurrentUser() {
    return auth().currentUser;
  }

  // Sign in with email and password
  async signInWithEmailAndPassword(email, password) {
    try {
      const userCredential = await auth().signInWithEmailAndPassword(email, password);
      return userCredential.user;
    } catch (error) {
      throw error;
    }
  }

  // Sign up with email and password
  async createUserWithEmailAndPassword(email, password, displayName) {
    try {
      const userCredential = await auth().createUserWithEmailAndPassword(email, password);
      
      // Update the user's profile
      await userCredential.user.updateProfile({
        displayName,
      });
      
      // Create a user document in Firestore
      await firestore().collection('users').doc(userCredential.user.uid).set({
        email,
        displayName,
        eloRating: 1200,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        gamesDraw: 0,
        createdAt: firestore.FieldValue.serverTimestamp(),
        lastLoginAt: firestore.FieldValue.serverTimestamp(),
      });
      
      return userCredential.user;
    } catch (error) {
      throw error;
    }
  }

  // Sign out
  async signOut() {
    try {
      await auth().signOut();
    } catch (error) {
      throw error;
    }
  }

  // Reset password
  async resetPassword(email) {
    try {
      await auth().sendPasswordResetEmail(email);
    } catch (error) {
      throw error;
    }
  }

  // Update user profile
  async updateProfile(displayName, photoURL) {
    try {
      const user = auth().currentUser;
      if (user) {
        await user.updateProfile({
          displayName: displayName || user.displayName,
          photoURL: photoURL || user.photoURL,
        });
      }
    } catch (error) {
      throw error;
    }
  }

  // Listen for auth state changes
  onAuthStateChanged(callback) {
    return auth().onAuthStateChanged(callback);
  }
}

export default new AuthService();
```

### Firestore Service

Create a file `src/services/firebase/firestoreService.js`:

```javascript
import { firestore } from './index';

class FirestoreService {
  // Get a user by ID
  async getUser(userId) {
    try {
      const doc = await firestore().collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (error) {
      throw error;
    }
  }

  // Update a user's data
  async updateUser(userId, data) {
    try {
      await firestore().collection('users').doc(userId).update({
        ...data,
        updatedAt: firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw error;
    }
  }

  // Create a new game
  async createGame(gameData) {
    try {
      const gameRef = await firestore().collection('games').add({
        ...gameData,
        createdAt: firestore.FieldValue.serverTimestamp(),
        updatedAt: firestore.FieldValue.serverTimestamp(),
      });
      return gameRef.id;
    } catch (error) {
      throw error;
    }
  }

  // Get a game by ID
  async getGame(gameId) {
    try {
      const doc = await firestore().collection('games').doc(gameId).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    } catch (error) {
      throw error;
    }
  }

  // Update a game
  async updateGame(gameId, data) {
    try {
      await firestore().collection('games').doc(gameId).update({
        ...data,
        updatedAt: firestore.FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw error;
    }
  }

  // Listen for game changes
  onGameChanged(gameId, callback) {
    return firestore()
      .collection('games')
      .doc(gameId)
      .onSnapshot(doc => {
        if (doc.exists) {
          callback({ id: doc.id, ...doc.data() });
        }
      });
  }

  // Get user's games
  async getUserGames(userId, limit = 10) {
    try {
      const snapshot = await firestore()
        .collection('games')
        .where('players', 'array-contains', userId)
        .orderBy('createdAt', 'desc')
        .limit(limit)
        .get();
      
      return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
      throw error;
    }
  }

  // Create or update user settings
  async updateUserSettings(userId, settings) {
    try {
      await firestore().collection('userSettings').doc(userId).set(
        { ...settings, updatedAt: firestore.FieldValue.serverTimestamp() },
        { merge: true }
      );
    } catch (error) {
      throw error;
    }
  }

  // Get user settings
  async getUserSettings(userId) {
    try {
      const doc = await firestore().collection('userSettings').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (error) {
      throw error;
    }
  }
}

export default new FirestoreService();
```

### Storage Service

Create a file `src/services/firebase/storageService.js`:

```javascript
import { storage } from './index';

class StorageService {
  // Upload a file
  async uploadFile(path, file, metadata = {}) {
    try {
      const reference = storage().ref(path);
      await reference.putFile(file, metadata);
      return await reference.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  // Download a file URL
  async getFileUrl(path) {
    try {
      const reference = storage().ref(path);
      return await reference.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  // Delete a file
  async deleteFile(path) {
    try {
      const reference = storage().ref(path);
      await reference.delete();
    } catch (error) {
      throw error;
    }
  }
}

export default new StorageService();
```

## Firestore Data Model

### Collections

1. **users**: User profiles and statistics
   ```
   users/{userId}
     - email: string
     - displayName: string
     - eloRating: number
     - gamesPlayed: number
     - gamesWon: number
     - gamesLost: number
     - gamesDraw: number
     - createdAt: timestamp
     - lastLoginAt: timestamp
   ```

2. **games**: Game records
   ```
   games/{gameId}
     - players: array<string> (user IDs)
     - playerData: map
       - {userId}: map
         - color: string ('red' or 'black')
         - rating: number
     - status: string ('active', 'completed', 'abandoned')
     - winner: string (user ID or 'draw')
     - startPosition: string (FEN notation)
     - currentPosition: string (FEN notation)
     - moves: array<map>
       - from: map
         - row: number
         - col: number
       - to: map
         - row: number
         - col: number
       - piece: string
       - capturedPiece: string
       - timestamp: timestamp
     - gameMode: string ('ranked', 'friendly', 'tournament')
     - timeControl: map
       - initialTime: number (seconds)
       - increment: number (seconds)
     - createdAt: timestamp
     - updatedAt: timestamp
     - completedAt: timestamp
   ```

3. **userSettings**: User preferences
   ```
   userSettings/{userId}
     - language: string
     - skin: string
     - soundEnabled: boolean
     - notificationsEnabled: boolean
     - updatedAt: timestamp
   ```

4. **tournaments**: Tournament data
   ```
   tournaments/{tournamentId}
     - name: string
     - description: string
     - startDate: timestamp
     - endDate: timestamp
     - status: string ('upcoming', 'active', 'completed')
     - participants: array<string> (user IDs)
     - rounds: array<map>
       - matches: array<map>
         - players: array<string> (user IDs)
         - gameId: string
         - winner: string (user ID or 'draw')
     - createdAt: timestamp
     - updatedAt: timestamp
   ```

## Security Rules

Create a file `firestore.rules` in your project root:

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

## Storage Rules

Create a file `storage.rules` in your project root:

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

## Conclusion

This setup provides a comprehensive Firebase integration for the Chinese Chess application, including authentication, data storage, and file storage. The security rules ensure that users can only access and modify their own data, while the data model supports all the features required for the game.

To deploy the security rules, you can use the Firebase CLI:

```bash
npm install -g firebase-tools
firebase login
firebase init
firebase deploy --only firestore:rules,storage:rules
```

With this setup, your React Native Chinese Chess application will have a solid backend infrastructure to support user accounts, game state synchronization, and asset management.
