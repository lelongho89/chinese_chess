import { Stack, SplashScreen } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { I18nextProvider } from 'react-i18next';
import { LogBox, Text } from 'react-native';
import { useEffect } from 'react';
import ErrorBoundary from '../src/components/ErrorBoundary';

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

// Patch the Error object to avoid the "Cannot redefine property: setError" error
if (!Error.prototype.hasOwnProperty('setError')) {
  Object.defineProperty(Error.prototype, 'setError', {
    configurable: true,
    enumerable: false,
    writable: true,
    value: function(error: any) {
      Object.defineProperty(this, 'message', {
        configurable: true,
        enumerable: false,
        writable: true,
        value: error.toString()
      });
    }
  });
}

import { store, persistor } from '../src/store';
import i18n from '../src/localization/i18n';

export default function RootLayout() {
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
              <Stack
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
              />
            </SafeAreaProvider>
          </I18nextProvider>
        </PersistGate>
      </Provider>
    </ErrorBoundary>
  );
}
