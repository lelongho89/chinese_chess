import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useAppSelector, useAppDispatch } from '../../hooks';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { initGame } from '../../store/actions';

/**
 * Props for the GameBottomBar component
 */
interface GameBottomBarProps {
  onUndoPress?: () => void;
  onRestartPress?: () => void;
  onHintPress?: () => void;
}

/**
 * GameBottomBar component for the Chinese Chess game
 * This component displays the game controls at the bottom of the screen
 */
const GameBottomBar: React.FC<GameBottomBarProps> = ({ 
  onUndoPress,
  onRestartPress,
  onHintPress
}) => {
  const dispatch = useAppDispatch();
  
  // Get state from Redux store
  const gameMode = useAppSelector(state => state.game.gameMode);
  const history = useAppSelector(state => state.game.history);
  
  // Handle undo button press
  const handleUndoPress = () => {
    if (onUndoPress) {
      onUndoPress();
    } else {
      // TODO: Implement undo functionality
      console.log('Undo pressed');
    }
  };
  
  // Handle restart button press
  const handleRestartPress = () => {
    if (onRestartPress) {
      onRestartPress();
    } else {
      // Restart the game
      dispatch(initGame({ gameMode: gameMode || 'ai' }));
    }
  };
  
  // Handle hint button press
  const handleHintPress = () => {
    if (onHintPress) {
      onHintPress();
    } else {
      // TODO: Implement hint functionality
      console.log('Hint pressed');
    }
  };
  
  return (
    <View style={styles.container}>
      <TouchableOpacity 
        style={[styles.button, history.length === 0 && styles.disabledButton]} 
        onPress={handleUndoPress}
        disabled={history.length === 0}
      >
        <Icon name="undo" size={24} color={history.length === 0 ? '#999' : '#333'} />
        <Text style={[styles.buttonText, history.length === 0 && styles.disabledText]}>Undo</Text>
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.button} onPress={handleRestartPress}>
        <Icon name="refresh" size={24} color="#333" />
        <Text style={styles.buttonText}>Restart</Text>
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.button} onPress={handleHintPress}>
        <Icon name="lightbulb-outline" size={24} color="#333" />
        <Text style={styles.buttonText}>Hint</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#f5f5f5',
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  button: {
    alignItems: 'center',
    padding: 8,
  },
  buttonText: {
    fontSize: 12,
    marginTop: 4,
    color: '#333',
  },
  disabledButton: {
    opacity: 0.5,
  },
  disabledText: {
    color: '#999',
  },
});

export default GameBottomBar;
