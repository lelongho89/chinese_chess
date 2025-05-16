/**
 * Navigation types for the Chinese Chess application
 */

import { RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';

// Define the screens in the main stack navigator
export type RootStackParamList = {
  Home: undefined;
  Game: { gameMode: 'ai' | 'online' | 'free' };
  Settings: undefined;
  About: undefined;
};

// Navigation prop types for each screen
export type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;
export type GameScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Game'>;
export type SettingsScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Settings'>;
export type AboutScreenNavigationProp = StackNavigationProp<RootStackParamList, 'About'>;

// Route prop types for each screen
export type HomeScreenRouteProp = RouteProp<RootStackParamList, 'Home'>;
export type GameScreenRouteProp = RouteProp<RootStackParamList, 'Game'>;
export type SettingsScreenRouteProp = RouteProp<RootStackParamList, 'Settings'>;
export type AboutScreenRouteProp = RouteProp<RootStackParamList, 'About'>;
