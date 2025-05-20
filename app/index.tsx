import { useEffect } from 'react';
import { Text, View, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { useAppSelector } from '../src/hooks';

export default function Index() {
  const router = useRouter();
  const { user, isLoading } = useAppSelector((state) => state.auth);

  useEffect(() => {
    // Redirect based on authentication state
    if (!isLoading) {
      if (user) {
        router.replace('/home');
      } else {
        router.replace('/auth/login');
      }
    }
  }, [user, isLoading, router]);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Chinese Chess</Text>
      <Text style={styles.subtitle}>Loading...</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
  },
});
