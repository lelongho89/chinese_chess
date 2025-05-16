import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import { RootStackParamList } from './types';

// Import screens
import HomeScreen from '../screens/HomeScreen';
import GameScreen from '../screens/GameScreen';
import SettingsScreen from '../screens/SettingsScreen';
import AboutScreen from '../screens/AboutScreen';

const Stack = createStackNavigator<RootStackParamList>();

/**
 * Main navigation component for the Chinese Chess application
 */
const AppNavigator: React.FC = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#f4511e',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}>
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
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
