import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Image } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { HomeScreenNavigationProp } from '../navigation/types';
import { useLocalization } from '../hooks/useLocalization';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Home screen component for the Chinese Chess application
 */
const HomeScreen: React.FC = () => {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const { t } = useLocalization();

  // Game mode options
  const gameModes = [
    {
      id: 'ai',
      title: t('game.modeRobot'),
      description: t('settings.aiLevel'),
      icon: 'smart-toy',
      color: '#f4511e',
    },
    {
      id: 'online',
      title: t('game.modeOnline'),
      description: t('auth.signIn'),
      icon: 'people',
      color: '#4CAF50',
    },
    {
      id: 'free',
      title: t('game.modeFree'),
      description: t('settings.boardOrientation'),
      icon: 'edit',
      color: '#2196F3',
    },
  ];

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('app.title')}</Text>
        <Text style={styles.subtitle}>Traditional Xiangqi Game</Text>
      </View>

      <View style={styles.buttonContainer}>
        {/* Game mode buttons */}
        {gameModes.map((mode) => (
          <TouchableOpacity
            key={mode.id}
            style={[styles.modeButton, { backgroundColor: mode.color }]}
            onPress={() => navigation.navigate('Game', { gameMode: mode.id as any })}
          >
            <View style={styles.modeIconContainer}>
              <Icon name={mode.icon} size={32} color="white" />
            </View>
            <View style={styles.modeTextContainer}>
              <Text style={styles.modeTitle}>{mode.title}</Text>
              <Text style={styles.modeDescription}>{mode.description}</Text>
            </View>
          </TouchableOpacity>
        ))}

        {/* Settings button */}
        <TouchableOpacity
          style={[styles.button, styles.settingsButton]}
          onPress={() => navigation.navigate('Settings')}>
          <Text style={styles.buttonText}>{t('settings.setting')}</Text>
        </TouchableOpacity>

        {/* Game History button */}
        <TouchableOpacity
          style={[styles.button, styles.historyButton]}
          onPress={() => navigation.navigate('GameHistory')}>
          <Text style={styles.buttonText}>{t('game.history')}</Text>
        </TouchableOpacity>

        {/* About button */}
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
  historyButton: {
    backgroundColor: '#8e44ad',
  },
  aboutButton: {
    backgroundColor: '#6b7f94',
  },
  // Game mode button styles
  modeButton: {
    flexDirection: 'row',
    backgroundColor: '#f4511e',
    borderRadius: 12,
    marginBottom: 15,
    width: '90%',
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  modeIconContainer: {
    padding: 16,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.1)',
  },
  modeTextContainer: {
    flex: 1,
    padding: 16,
    justifyContent: 'center',
  },
  modeTitle: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  modeDescription: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
  },
});

export default HomeScreen;
