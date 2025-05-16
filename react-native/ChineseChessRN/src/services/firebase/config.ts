/**
 * Firebase configuration for the Chinese Chess application
 */

// Firebase configuration object
// Replace these values with your actual Firebase project configuration
export const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID"
};

// Firebase collection names
export const collections = {
  USERS: 'users',
  GAMES: 'games',
  USER_SETTINGS: 'userSettings',
  TOURNAMENTS: 'tournaments',
};
