/**
 * Entry point for the Chinese Chess application
 *
 * This file registers the main App component with React Native's AppRegistry
 * and serves as the entry point for the application.
 */

import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from '../app.json';

// Register the main component with React Native
AppRegistry.registerComponent(appName, () => App);
