/**
 * Firebase services for the Chinese Chess application
 */
import { Platform } from 'react-native';
import firebase from '@react-native-firebase/app';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import storage from '@react-native-firebase/storage';
import analytics from '@react-native-firebase/analytics';

import { firebaseConfig } from './config';

/**
 * Initialize Firebase if it hasn't been initialized yet
 */
if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

/**
 * Enable Firestore offline persistence
 */
firestore().settings({
  persistence: true,
});

/**
 * Configure Analytics
 */
if (Platform.OS !== 'web') {
  analytics().setAnalyticsCollectionEnabled(true);
}

export { firebase, auth, firestore, storage, analytics };
