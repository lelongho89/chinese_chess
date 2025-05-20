import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAppSelector, useAppDispatch } from '../src/hooks';
import { setUser } from '../src/store/slices/authSlice';
import auth from '@react-native-firebase/auth';

export default function Home() {
  const router = useRouter();
  const dispatch = useAppDispatch();
  const { user } = useAppSelector((state) => state.auth);

  const handleLogout = async () => {
    try {
      await auth().signOut();
      dispatch(setUser(null));
      router.replace('/auth/login');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const handleStartGame = () => {
    router.push('/game');
  };

  const handleViewHistory = () => {
    router.push('/history');
  };

  const handleViewLeaderboard = () => {
    router.push('/leaderboard');
  };

  const handleSettings = () => {
    router.push('/settings');
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Chinese Chess</Text>
        <Text style={styles.subtitle}>Welcome, {user?.displayName || 'Player'}</Text>
      </View>

      <View style={styles.menuContainer}>
        <TouchableOpacity style={styles.menuItem} onPress={handleStartGame}>
          <Text style={styles.menuItemText}>Start New Game</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem} onPress={handleViewHistory}>
          <Text style={styles.menuItemText}>Game History</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem} onPress={handleViewLeaderboard}>
          <Text style={styles.menuItemText}>Leaderboard</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem} onPress={handleSettings}>
          <Text style={styles.menuItemText}>Settings</Text>
        </TouchableOpacity>

        <TouchableOpacity style={[styles.menuItem, styles.logoutButton]} onPress={handleLogout}>
          <Text style={[styles.menuItemText, styles.logoutText]}>Logout</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 20,
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
  },
  menuContainer: {
    padding: 20,
  },
  menuItem: {
    backgroundColor: '#f4511e',
    padding: 20,
    borderRadius: 8,
    marginBottom: 16,
    alignItems: 'center',
  },
  menuItemText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  logoutButton: {
    backgroundColor: '#fff',
    borderWidth: 2,
    borderColor: '#f4511e',
    marginTop: 20,
  },
  logoutText: {
    color: '#f4511e',
  },
});
