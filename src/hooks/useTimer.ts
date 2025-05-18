import { useState, useEffect, useRef } from 'react';
import { ChessTimer, TimerState } from '../models/ChessTimer';
import { GameTimerManager } from '../models/GameTimerManager';
import { useAppSelector, useAppDispatch } from './index';
import { setGameResult } from '../store/slices/gameSlice';

/**
 * Custom hook for managing chess timers
 * @param initialTimeSeconds Initial time in seconds (default: 180 seconds = 3 minutes)
 * @param incrementSeconds Time increment in seconds after each move (default: 2 seconds)
 */
export const useTimer = (
  initialTimeSeconds: number = 180,
  incrementSeconds: number = 2
) => {
  const dispatch = useAppDispatch();
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  const isGameActive = useAppSelector(state => state.game.isGameActive);
  
  // Create a ref for the timer manager to persist across renders
  const timerManagerRef = useRef<GameTimerManager | null>(null);
  
  // State for timer values
  const [redTime, setRedTime] = useState('03:00');
  const [blackTime, setBlackTime] = useState('03:00');
  const [redTimerState, setRedTimerState] = useState<TimerState>(TimerState.READY);
  const [blackTimerState, setBlackTimerState] = useState<TimerState>(TimerState.READY);
  const [isEnabled, setIsEnabled] = useState(false);
  
  // Initialize timer manager
  useEffect(() => {
    if (!timerManagerRef.current) {
      timerManagerRef.current = new GameTimerManager(initialTimeSeconds, incrementSeconds);
      
      // Add listener to update UI when timers change
      timerManagerRef.current.addListener(updateTimerDisplay);
    }
    
    return () => {
      // Clean up on unmount
      if (timerManagerRef.current) {
        timerManagerRef.current.dispose();
        timerManagerRef.current = null;
      }
    };
  }, [initialTimeSeconds, incrementSeconds]);
  
  // Update timer display
  const updateTimerDisplay = () => {
    if (!timerManagerRef.current) return;
    
    const redTimer = timerManagerRef.current.getTimerForPlayer('red');
    const blackTimer = timerManagerRef.current.getTimerForPlayer('black');
    
    setRedTime(redTimer.getFormattedTime());
    setBlackTime(blackTimer.getFormattedTime());
    setRedTimerState(redTimer.getState());
    setBlackTimerState(blackTimer.getState());
    setIsEnabled(timerManagerRef.current.isEnabled());
    
    // Check for timer expiration
    if (redTimer.isExpired()) {
      // Red player lost on time
      dispatch(setGameResult({
        winner: 'black',
        reason: 'timeout'
      }));
    } else if (blackTimer.isExpired()) {
      // Black player lost on time
      dispatch(setGameResult({
        winner: 'red',
        reason: 'timeout'
      }));
    }
  };
  
  // Effect to handle player changes
  useEffect(() => {
    if (timerManagerRef.current && isGameActive && isEnabled) {
      timerManagerRef.current.switchPlayer(currentPlayer);
    }
  }, [currentPlayer, isGameActive, isEnabled]);
  
  // Effect to handle game state changes
  useEffect(() => {
    if (!timerManagerRef.current) return;
    
    if (isGameActive) {
      if (isEnabled) {
        timerManagerRef.current.resumeCurrent();
      }
    } else {
      timerManagerRef.current.pauseAll();
    }
  }, [isGameActive, isEnabled]);
  
  // Functions to control the timer
  const startNewGame = () => {
    if (timerManagerRef.current) {
      timerManagerRef.current.startNewGame();
    }
  };
  
  const toggleEnabled = () => {
    if (timerManagerRef.current) {
      timerManagerRef.current.setEnabled(!isEnabled);
    }
  };
  
  const pauseAll = () => {
    if (timerManagerRef.current) {
      timerManagerRef.current.pauseAll();
    }
  };
  
  const resumeCurrent = () => {
    if (timerManagerRef.current) {
      timerManagerRef.current.resumeCurrent();
    }
  };
  
  return {
    redTime,
    blackTime,
    redTimerState,
    blackTimerState,
    isEnabled,
    startNewGame,
    toggleEnabled,
    pauseAll,
    resumeCurrent
  };
};
