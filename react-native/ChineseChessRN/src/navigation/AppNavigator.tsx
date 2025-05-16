import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';
import { GoogleSignin } from '@react-native-google-signin/google-signin';

import { RootStackParamList } from './types';
import { useAppDispatch, useAppSelector } from '../hooks';
import { setUser, setLoading } from '../store/slices/authSlice';

// Import screens
import HomeScreen from '../screens/HomeScreen';
import GameScreen from '../screens/GameScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AboutScreen from '../screens/AboutScreen';

// Import auth screens
import {
  LoginScreen,
  RegisterScreen,
  ForgotPasswordScreen,
  ProfileScreen
} from '../screens/auth';

const Stack = createStackNavigator<RootStackParamList>();

/**
 * Main navigation component for the Chinese Chess application
 */
const AppNavigator: React.FC = () => {
  const dispatch = useAppDispatch();
  const { user, isLoading } = useAppSelector(state => state.auth);
  const [initializing, setInitializing] = useState(true);

  // Configure Google Sign-In
  useEffect(() => {
    GoogleSignin.configure({
      webClientId: '1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com', // Replace with your web client ID
    });
  }, []);

  // Handle auth state changes
  useEffect(() => {
    dispatch(setLoading(true));

    // Subscribe to auth state changes
    const unsubscribe = auth().onAuthStateChanged(async (firebaseUser) => {
      if (firebaseUser) {
        // User is signed in
        try {
          // Get user data from Firestore
          const userDoc = await firestore().collection('users').doc(firebaseUser.uid).get();

          if (userDoc.exists) {
            dispatch(setUser(userDoc.data() as any));
          } else {
            // Create user document if it doesn't exist
            const newUser = {
              id: firebaseUser.uid,
              email: firebaseUser.email || '',
              displayName: firebaseUser.displayName || 'User',
              photoURL: firebaseUser.photoURL,
              eloRating: 1200,
              gamesPlayed: 0,
              gamesWon: 0,
              gamesLost: 0,
              gamesDraw: 0,
            };

            await firestore().collection('users').doc(firebaseUser.uid).set(newUser);
            dispatch(setUser(newUser));
          }
        } catch (error) {
          console.error('Error getting user data:', error);
        }
      } else {
        // User is signed out
        dispatch(setUser(null));
      }

      dispatch(setLoading(false));
      if (initializing) setInitializing(false);
    });

    // Unsubscribe on cleanup
    return unsubscribe;
  }, [dispatch, initializing]);

  // Define common screen options
  const screenOptions = {
    headerStyle: {
      backgroundColor: '#f4511e',
    },
    headerTintColor: '#fff',
    headerTitleStyle: {
      fontWeight: 'bold',
    },
  };

  // Show loading screen while initializing
  if (initializing) {
    return null; // Or a loading screen component
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName={user ? 'Home' : 'Login'}
        screenOptions={screenOptions}>
        {user ? (
          // Authenticated user screens
          <>
            <Stack.Screen
              name="Home"
              component={HomeScreen}
              options={{ title: 'Chinese Chess' }}
            />
            <Stack.Screen
              name="Game"
              component={GameScreen}
              options={({ route }) => ({
                title: `Game - ${route.params.gameMode.toUpperCase()} Mode`
              })}
            />
            <Stack.Screen
              name="Settings"
              component={SettingsScreen}
              options={{ title: 'Settings' }}
            />
            <Stack.Screen
              name="About"
              component={AboutScreen}
              options={{ title: 'About' }}
            />
            <Stack.Screen
              name="Profile"
              component={ProfileScreen}
              options={{ title: 'My Profile' }}
            />
          </>
        ) : (
          // Unauthenticated user screens
          <>
            <Stack.Screen
              name="Login"
              component={LoginScreen}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="Register"
              component={RegisterScreen}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="ForgotPassword"
              component={ForgotPasswordScreen}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="Home"
              component={HomeScreen}
              options={{ title: 'Chinese Chess' }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
