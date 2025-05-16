import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAppSelector } from '../../hooks';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Props for the GameHeader component
 */
interface GameHeaderProps {
  onBackPress?: () => void;
  onSettingsPress?: () => void;
}

/**
 * GameHeader component for the Chinese Chess game
 * This component displays the game header with player information and controls
 */
const GameHeader: React.FC<GameHeaderProps> = ({ 
  onBackPress,
  onSettingsPress
}) => {
  const navigation = useNavigation();
  
  // Get state from Redux store
  const gameMode = useAppSelector(state => state.game.gameMode);
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  
  // Handle back button press
  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else {
      navigation.goBack();
    }
  };
  
  // Handle settings button press
  const handleSettingsPress = () => {
    if (onSettingsPress) {
      onSettingsPress();
    } else {
      navigation.navigate('Settings' as never);
    }
  };
  
  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.backButton} onPress={handleBackPress}>
        <Icon name="arrow-back" size={24} color="#333" />
      </TouchableOpacity>
      
      <View style={styles.titleContainer}>
        <Text style={styles.title}>
          {gameMode ? `${gameMode.toUpperCase()} Mode` : 'Chinese Chess'}
        </Text>
        <Text style={[
          styles.playerText,
          { color: currentPlayer === 'red' ? '#d32f2f' : '#333' }
        ]}>
          {currentPlayer === 'red' ? 'Red' : 'Black'}'s Turn
        </Text>
      </View>
      
      <TouchableOpacity style={styles.settingsButton} onPress={handleSettingsPress}>
        <Icon name="settings" size={24} color="#333" />
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#f5f5f5',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButton: {
    padding: 8,
  },
  titleContainer: {
    flex: 1,
    alignItems: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  playerText: {
    fontSize: 14,
    marginTop: 4,
  },
  settingsButton: {
    padding: 8,
  },
});

export default GameHeader;
