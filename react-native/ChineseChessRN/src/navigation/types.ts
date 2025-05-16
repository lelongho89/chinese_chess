/**
 * Navigation types for the Chinese Chess application
 */

import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

// Define the screens in the main stack navigator
export type RootStackParamList = {
  // Auth screens
  Login: undefined;
  Register: undefined;
  ForgotPassword: undefined;
  Profile: undefined;

  // Main screens
  Home: undefined;
  Game: { gameMode: 'ai' | 'online' | 'free' };
  Settings: undefined;
  About: undefined;
};

// Navigation prop types for each screen
// Auth screens
export type LoginScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Login'>;
export type RegisterScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Register'>;
export type ForgotPasswordScreenNavigationProp = StackNavigationProp<RootStackParamList, 'ForgotPassword'>;
export type ProfileScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Profile'>;

// Main screens
export type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;
export type GameScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Game'>;
export type SettingsScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Settings'>;
export type AboutScreenNavigationProp = StackNavigationProp<RootStackParamList, 'About'>;

// Route prop types for each screen
// Auth screens
export type LoginScreenRouteProp = RouteProp<RootStackParamList, 'Login'>;
export type RegisterScreenRouteProp = RouteProp<RootStackParamList, 'Register'>;
export type ForgotPasswordScreenRouteProp = RouteProp<RootStackParamList, 'ForgotPassword'>;
export type ProfileScreenRouteProp = RouteProp<RootStackParamList, 'Profile'>;

// Main screens
export type HomeScreenRouteProp = RouteProp<RootStackParamList, 'Home'>;
export type GameScreenRouteProp = RouteProp<RootStackParamList, 'Game'>;
export type SettingsScreenRouteProp = RouteProp<RootStackParamList, 'Settings'>;
export type AboutScreenRouteProp = RouteProp<RootStackParamList, 'About'>;
