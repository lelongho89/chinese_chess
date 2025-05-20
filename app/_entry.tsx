import { Text, View, StyleSheet } from 'react-native';
import { SplashScreen } from 'expo-router';
import { useEffect } from 'react';
import ErrorBoundary from '../src/components/ErrorBoundary';

// Prevent the splash screen from auto-hiding before asset loading is complete.
SplashScreen.preventAutoHideAsync();

export default function RootEntryPoint() {
  useEffect(() => {
    // Hide the splash screen after the assets have been loaded and the UI is ready.
    SplashScreen.hideAsync();
  }, []);

  // Handle the "Cannot redefine property: setError" error by wrapping the app in an ErrorBoundary
  return (
    <ErrorBoundary
      fallback={
        <View style={styles.container}>
          <Text style={styles.title}>Chinese Chess</Text>
          <Text style={styles.message}>
            We're experiencing some technical difficulties. Please try again later.
          </Text>
        </View>
      }
    >
      {/* Import the app layout after the error boundary */}
      {require('./index')}
    </ErrorBoundary>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#f4511e',
  },
  message: {
    fontSize: 16,
    marginBottom: 24,
    textAlign: 'center',
    color: '#333',
  },
});
