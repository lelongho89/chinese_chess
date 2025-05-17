import React, { useEffect, memo } from 'react';
import { StatusBar, useColorScheme } from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { enableScreens } from 'react-native-screens';
import { Provider } from 'react-redux';
import { PersistGate } from 'redux-persist/integration/react';
import { I18nextProvider } from 'react-i18next';

import AppNavigator from './navigation/AppNavigator';
import { store, persistor } from './store';
import i18n from './localization/i18n';
import { PerformanceMonitor } from './utils/performance';

// Enable screens for better navigation performance
enableScreens();

/**
 * StatusBar component memoized to prevent unnecessary re-renders
 */
const AppStatusBar = memo(() => {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <StatusBar
      barStyle={isDarkMode ? 'light-content' : 'dark-content'}
      backgroundColor={isDarkMode ? Colors.darker : Colors.lighter}
    />
  );
});

/**
 * Main App component for Chinese Chess
 */
function App(): React.JSX.Element {
  // Use performance monitoring in development mode
  useEffect(() => {
    if (__DEV__) {
      // Enable additional development-only performance optimizations
      console.log('Development mode: Performance monitoring enabled');
    }
  }, []);

  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <I18nextProvider i18n={i18n}>
          <SafeAreaProvider>
            <AppStatusBar />
            <AppNavigator />
            {__DEV__ && <PerformanceMonitor />}
          </SafeAreaProvider>
        </I18nextProvider>
      </PersistGate>
    </Provider>
  );
}

export default memo(App);
