import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { I18nextProvider } from 'react-i18next';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { LogBox } from 'react-native';
import * as SplashScreen from 'expo-splash-screen';

// Import screens
import HomeScreen from './screens/HomeScreen';
import LoginScreen from './screens/LoginScreen';

// Import store and i18n
import { store, persistor } from './store';
import i18n from './localization/i18n';

// Import ErrorBoundary
import ErrorBoundary from './components/ErrorBoundary';

// Prevent the splash screen from auto-hiding
SplashScreen.preventAutoHideAsync().catch(() => {
  /* reloading the app might trigger some race conditions, ignore them */
});

// Ignore specific warnings
LogBox.ignoreLogs([
  'Cannot redefine property: setError',
  'Require cycle:',
  'Warning: Failed prop type',
  'Overwriting fontFamily style attribute preprocessor',
]);

// Create the stack navigator
const Stack = createStackNavigator();

/**
 * Main App component for Chinese Chess
 */
function AppEntry(): React.JSX.Element {
  useEffect(() => {
    // Hide the splash screen after the assets have been loaded and the UI is ready.
    setTimeout(() => {
      SplashScreen.hideAsync().catch(() => {
        // Ignore errors
      });
    }, 1000);
  }, []);

  return (
    <ErrorBoundary>
      <Provider store={store}>
        <PersistGate loading={null} persistor={persistor}>
          <I18nextProvider i18n={i18n}>
            <SafeAreaProvider>
              <StatusBar style="auto" />
              <NavigationContainer>
                <Stack.Navigator
                  initialRouteName="Login"
                  screenOptions={{
                    headerStyle: {
                      backgroundColor: '#f4511e',
                    },
                    headerTintColor: '#fff',
                    headerTitleStyle: {
                      fontWeight: 'bold',
                    },
                    headerBackTitleVisible: false,
                    cardStyle: { backgroundColor: '#fff' },
                    animationEnabled: true,
                  }}
                >
                  <Stack.Screen 
                    name="Login" 
                    component={LoginScreen} 
                    options={{ title: 'Sign In' }}
                  />
                  <Stack.Screen 
                    name="Home" 
                    component={HomeScreen} 
                    options={{ title: 'Chinese Chess' }}
                  />
                </Stack.Navigator>
              </NavigationContainer>
            </SafeAreaProvider>
          </I18nextProvider>
        </PersistGate>
      </Provider>
    </ErrorBoundary>
  );
}

export default AppEntry;
