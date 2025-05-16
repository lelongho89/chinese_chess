import React from 'react';
import { View, StyleSheet } from 'react-native';
import ChessTimerComponent from './ChessTimerComponent';
import TimerControls from './TimerControls';
import { useAppSelector, useAppDispatch } from '../../hooks';
import { useTimer } from '../../hooks/useTimer';
import { setTimerEnabled } from '../../store/slices/gameSlice';

interface GameTimerDisplayProps {
  isCompact?: boolean;
  showControls?: boolean;
}

/**
 * Component to display both player timers and controls
 */
const GameTimerDisplay: React.FC<GameTimerDisplayProps> = ({
  isCompact = false,
  showControls = true,
}) => {
  const dispatch = useAppDispatch();
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  const timerEnabled = useAppSelector(state => state.game.timerEnabled);
  const initialTimeSeconds = useAppSelector(state => state.game.initialTimeSeconds);
  const incrementSeconds = useAppSelector(state => state.game.incrementSeconds);
  
  // Use the timer hook
  const {
    redTime,
    blackTime,
    redTimerState,
    blackTimerState,
    isEnabled,
    startNewGame,
    toggleEnabled,
  } = useTimer(initialTimeSeconds, incrementSeconds);
  
  // Handle toggle enabled
  const handleToggleEnabled = () => {
    toggleEnabled();
    dispatch(setTimerEnabled(!timerEnabled));
  };
  
  // Handle reset
  const handleReset = () => {
    startNewGame();
  };
  
  return (
    <View style={styles.container}>
      {/* Black player timer */}
      <ChessTimerComponent
        time={blackTime}
        timerState={blackTimerState}
        isActive={isEnabled && currentPlayer === 'black'}
        color="#000000"
        isCompact={isCompact}
      />
      
      {/* Timer controls */}
      {showControls && (
        <View style={styles.controlsContainer}>
          <TimerControls
            isEnabled={isEnabled}
            onToggleEnabled={handleToggleEnabled}
            onReset={handleReset}
          />
        </View>
      )}
      
      {/* Red player timer */}
      <ChessTimerComponent
        time={redTime}
        timerState={redTimerState}
        isActive={isEnabled && currentPlayer === 'red'}
        color="#ff0000"
        isCompact={isCompact}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  controlsContainer: {
    marginVertical: 8,
  },
});

export default GameTimerDisplay;
