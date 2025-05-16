import React from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { TimerState } from '../../models/ChessTimer';
import PulsingDot from './PulsingDot';
import Icon from 'react-native-vector-icons/MaterialIcons';

interface ChessTimerComponentProps {
  time: string;
  timerState: TimerState;
  isActive: boolean;
  color: string;
  isCompact?: boolean;
}

/**
 * Component to display a chess timer for a single player
 */
const ChessTimerComponent: React.FC<ChessTimerComponentProps> = ({
  time,
  timerState,
  isActive,
  color,
  isCompact = false,
}) => {
  // Determine the color based on time remaining and active state
  const getTimeColor = () => {
    if (timerState === TimerState.EXPIRED) {
      return '#ff0000'; // Red for expired
    }
    
    if (isActive) {
      return color; // Player color when active
    }
    
    return '#666666'; // Gray when inactive
  };
  
  // Build state indicator based on timer state
  const renderStateIndicator = () => {
    if (isCompact) {
      return null;
    }
    
    switch (timerState) {
      case TimerState.RUNNING:
        return <PulsingDot color="#4CAF50" />;
      case TimerState.PAUSED:
        return <Icon name="pause" color="#FFA000" size={16} />;
      case TimerState.EXPIRED:
        return <Icon name="flag" color="#F44336" size={16} />;
      case TimerState.STOPPED:
        return <Icon name="stop" color="#9E9E9E" size={16} />;
      case TimerState.READY:
        return <Icon name="play-arrow" color="#2196F3" size={16} />;
      default:
        return null;
    }
  };
  
  return (
    <Animated.View
      style={[
        styles.container,
        isCompact ? styles.compactContainer : styles.fullContainer,
        {
          backgroundColor: isActive ? `${color}20` : 'transparent', // 20 is for 12% opacity
          borderColor: isActive ? color : '#e0e0e0',
          borderWidth: isActive ? 2 : 1,
        },
      ]}
    >
      <Icon
        name="timer"
        size={isCompact ? 16 : 24}
        color={getTimeColor()}
      />
      
      <Text
        style={[
          styles.timeText,
          isCompact ? styles.compactText : styles.fullText,
          {
            color: getTimeColor(),
            fontWeight: isActive ? 'bold' : 'normal',
          },
        ]}
      >
        {time}
      </Text>
      
      {renderStateIndicator()}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 8,
  },
  compactContainer: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  fullContainer: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  timeText: {
    fontFamily: 'monospace',
  },
  compactText: {
    fontSize: 16,
    marginLeft: 4,
  },
  fullText: {
    fontSize: 24,
    marginLeft: 8,
  },
});

export default ChessTimerComponent;
