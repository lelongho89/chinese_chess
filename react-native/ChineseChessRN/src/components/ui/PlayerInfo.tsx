import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';

/**
 * Props for the PlayerInfo component
 */
interface PlayerInfoProps {
  color: 'red' | 'black';
  name: string;
  isCurrentPlayer: boolean;
  capturedPieces?: string[];
  timeLeft?: number;
  avatar?: string;
}

/**
 * PlayerInfo component for the Chinese Chess game
 * This component displays information about a player
 */
const PlayerInfo: React.FC<PlayerInfoProps> = ({ 
  color,
  name,
  isCurrentPlayer,
  capturedPieces = [],
  timeLeft,
  avatar
}) => {
  // Format time left
  const formatTime = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`;
  };
  
  return (
    <View style={[
      styles.container,
      isCurrentPlayer && styles.activeContainer,
      color === 'red' ? styles.redContainer : styles.blackContainer
    ]}>
      <View style={styles.playerInfo}>
        {avatar ? (
          <Image source={{ uri: avatar }} style={styles.avatar} />
        ) : (
          <View style={[
            styles.colorIndicator,
            color === 'red' ? styles.redIndicator : styles.blackIndicator
          ]} />
        )}
        
        <View style={styles.nameContainer}>
          <Text style={[
            styles.nameText,
            isCurrentPlayer && styles.activeText
          ]}>
            {name}
          </Text>
          
          {timeLeft !== undefined && (
            <Text style={styles.timeText}>
              {formatTime(timeLeft)}
            </Text>
          )}
        </View>
      </View>
      
      {capturedPieces.length > 0 && (
        <View style={styles.capturedContainer}>
          <Text style={styles.capturedText}>
            Captured: {capturedPieces.join(', ')}
          </Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 8,
    borderRadius: 4,
    marginHorizontal: 8,
    marginVertical: 4,
    backgroundColor: '#f5f5f5',
  },
  activeContainer: {
    backgroundColor: '#e3f2fd',
    borderWidth: 1,
    borderColor: '#2196f3',
  },
  redContainer: {
    borderLeftWidth: 4,
    borderLeftColor: '#d32f2f',
  },
  blackContainer: {
    borderLeftWidth: 4,
    borderLeftColor: '#333',
  },
  playerInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  colorIndicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
    marginRight: 8,
  },
  redIndicator: {
    backgroundColor: '#d32f2f',
  },
  blackIndicator: {
    backgroundColor: '#333',
  },
  avatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    marginRight: 8,
  },
  nameContainer: {
    flex: 1,
  },
  nameText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
  },
  activeText: {
    color: '#2196f3',
  },
  timeText: {
    fontSize: 12,
    color: '#666',
  },
  capturedContainer: {
    marginTop: 4,
  },
  capturedText: {
    fontSize: 12,
    color: '#666',
  },
});

export default PlayerInfo;
