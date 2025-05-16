import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { HomeScreenNavigationProp } from '../navigation/types';

/**
 * Home screen component for the Chinese Chess application
 */
const HomeScreen: React.FC = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Chinese Chess</Text>
        <Text style={styles.subtitle}>Traditional Xiangqi Game</Text>
      </View>

      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Game', { gameMode: 'ai' })}>
          <Text style={styles.buttonText}>Play vs AI</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Game', { gameMode: 'online' })}>
          <Text style={styles.buttonText}>Online Play</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.navigate('Game', { gameMode: 'free' })}>
          <Text style={styles.buttonText}>Free Play</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.settingsButton]}
          onPress={() => navigation.navigate('Settings')}>
          <Text style={styles.buttonText}>Settings</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.aboutButton]}
          onPress={() => navigation.navigate('About')}>
          <Text style={styles.buttonText}>About</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    alignItems: 'center',
    padding: 20,
    marginTop: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
    marginBottom: 30,
  },
  buttonContainer: {
    flex: 1,
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  button: {
    backgroundColor: '#f4511e',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 8,
    marginBottom: 15,
    width: '80%',
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  settingsButton: {
    backgroundColor: '#4a6ea9',
    marginTop: 20,
  },
  aboutButton: {
    backgroundColor: '#6b7f94',
  },
});

export default HomeScreen;
