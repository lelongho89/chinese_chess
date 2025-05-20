import { createAsyncThunk } from '@reduxjs/toolkit';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { setUser, setLoading, setError, updateUserStats, logout } from '../slices/authSlice';
import { AppDispatch, RootState } from '../rootReducer';
import { User } from '../slices/authSlice';

/**
 * Register a new user with email and password
 */
export const registerUser = createAsyncThunk<
  void,
  { name: string; email: string; password: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/registerUser',
  async ({ name, email, password }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Create user with email and password
      const userCredential = await auth().createUserWithEmailAndPassword(email, password);
      
      // Update user profile
      await userCredential.user.updateProfile({
        displayName: name,
      });
      
      // Create user document in Firestore
      await firestore().collection('users').doc(userCredential.user.uid).set({
        id: userCredential.user.uid,
        email: email,
        displayName: name,
        eloRating: 1200,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        gamesDraw: 0,
        createdAt: firestore.FieldValue.serverTimestamp(),
      });
      
      // Don't automatically sign in after registration
      await auth().signOut();
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to register user');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Login user with email and password
 */
export const loginUser = createAsyncThunk<
  void,
  { email: string; password: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/loginUser',
  async ({ email, password }, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Sign in with email and password
      const userCredential = await auth().signInWithEmailAndPassword(email, password);
      
      // Get user data from Firestore
      const userDoc = await firestore().collection('users').doc(userCredential.user.uid).get();
      
      if (userDoc.exists) {
        const userData = userDoc.data() as User;
        dispatch(setUser(userData));
      } else {
        // Create user document if it doesn't exist
        const newUser: User = {
          id: userCredential.user.uid,
          email: userCredential.user.email || email,
          displayName: userCredential.user.displayName || email.split('@')[0],
          photoURL: userCredential.user.photoURL || undefined,
          eloRating: 1200,
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
          gamesDraw: 0,
        };
        
        await firestore().collection('users').doc(userCredential.user.uid).set(newUser);
        dispatch(setUser(newUser));
      }
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to login');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Login with Google
 */
export const loginWithGoogle = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/loginWithGoogle',
  async (_, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Check if your device supports Google Play
      await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      
      // Get the users ID token
      const { idToken } = await GoogleSignin.signIn();
      
      // Create a Google credential with the token
      const googleCredential = auth.GoogleAuthProvider.credential(idToken);
      
      // Sign-in the user with the credential
      const userCredential = await auth().signInWithCredential(googleCredential);
      
      // Get user data from Firestore
      const userDoc = await firestore().collection('users').doc(userCredential.user.uid).get();
      
      if (userDoc.exists) {
        const userData = userDoc.data() as User;
        dispatch(setUser(userData));
      } else {
        // Create user document if it doesn't exist
        const newUser: User = {
          id: userCredential.user.uid,
          email: userCredential.user.email || '',
          displayName: userCredential.user.displayName || 'Google User',
          photoURL: userCredential.user.photoURL || undefined,
          eloRating: 1200,
          gamesPlayed: 0,
          gamesWon: 0,
          gamesLost: 0,
          gamesDraw: 0,
        };
        
        await firestore().collection('users').doc(userCredential.user.uid).set(newUser);
        dispatch(setUser(newUser));
      }
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to login with Google');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Reset password
 */
export const resetPassword = createAsyncThunk<
  void,
  string,
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/resetPassword',
  async (email, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Send password reset email
      await auth().sendPasswordResetEmail(email);
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to send password reset email');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Update user profile
 */
export const updateUserProfile = createAsyncThunk<
  void,
  { displayName?: string; photoURL?: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/updateUserProfile',
  async (profileData, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      const { user } = getState().auth;
      
      if (!user) {
        throw new Error('User not authenticated');
      }
      
      // Update Firebase Auth profile
      const currentUser = auth().currentUser;
      
      if (currentUser) {
        await currentUser.updateProfile(profileData);
      }
      
      // Update Firestore user document
      await firestore().collection('users').doc(user.id).update(profileData);
      
      // Update Redux state
      dispatch(updateUserStats(profileData));
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to update profile');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Change password
 */
export const changePassword = createAsyncThunk<
  void,
  { currentPassword: string; newPassword: string },
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/changePassword',
  async ({ currentPassword, newPassword }, { dispatch, getState }) => {
    try {
      dispatch(setLoading(true));
      
      const { user } = getState().auth;
      
      if (!user) {
        throw new Error('User not authenticated');
      }
      
      const currentUser = auth().currentUser;
      
      if (!currentUser || !currentUser.email) {
        throw new Error('User not found');
      }
      
      // Reauthenticate user
      const credential = auth.EmailAuthProvider.credential(currentUser.email, currentPassword);
      await currentUser.reauthenticateWithCredential(credential);
      
      // Change password
      await currentUser.updatePassword(newPassword);
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to change password');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);

/**
 * Logout user
 */
export const logoutUser = createAsyncThunk<
  void,
  void,
  { dispatch: AppDispatch; state: RootState }
>(
  'auth/logoutUser',
  async (_, { dispatch }) => {
    try {
      dispatch(setLoading(true));
      
      // Sign out from Firebase
      await auth().signOut();
      
      // Sign out from Google
      if (await GoogleSignin.isSignedIn()) {
        await GoogleSignin.signOut();
      }
      
      // Clear user data in Redux
      dispatch(logout());
      
      dispatch(setLoading(false));
    } catch (error) {
      dispatch(setLoading(false));
      
      if (error instanceof Error) {
        dispatch(setError(error.message));
        throw error;
      } else {
        const genericError = new Error('Failed to logout');
        dispatch(setError(genericError.message));
        throw genericError;
      }
    }
  }
);
