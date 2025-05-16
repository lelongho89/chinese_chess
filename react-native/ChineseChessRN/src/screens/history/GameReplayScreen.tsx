import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  ActivityIndicator,
  ScrollView,
  Slider,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useAppDispatch, useAppSelector } from '../../hooks';
import { ChessBoard } from '../../components/board';
import {
  getGameFromHistory,
  loadGameForReplay,
} from '../../store/actions';
import { GameReplayService, ReplayEvent } from '../../services/history';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Game replay screen component for the Chinese Chess application
 */
const GameReplayScreen: React.FC = () => {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  
  // Get state from Redux store
  const { currentGame, isLoading } = useAppSelector(state => state.game);
  
  // State for replay controls
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentMoveIndex, setCurrentMoveIndex] = useState(-1);
  const [totalMoves, setTotalMoves] = useState(0);
  const [replaySpeed, setReplaySpeed] = useState(1000); // 1 second per move
  
  // Load the game when the component mounts
  useEffect(() => {
    const { gameId } = route.params;
    
    if (gameId) {
      dispatch(getGameFromHistory({ gameId }))
        .unwrap()
        .then(game => {
          if (game) {
            dispatch(loadGameForReplay({ game }));
            setTotalMoves(game.moves.length);
          }
        });
    }
  }, [dispatch, route.params]);
  
  // Set up event listeners for the replay service
  useEffect(() => {
    const handleMoveChanged = (data: any) => {
      setCurrentMoveIndex(data.moveIndex);
    };
    
    const handleReplayStarted = () => {
      setIsPlaying(true);
    };
    
    const handleReplayPaused = () => {
      setIsPlaying(false);
    };
    
    const handleReplayCompleted = () => {
      setIsPlaying(false);
    };
    
    // Add event listeners
    GameReplayService.on(ReplayEvent.MOVE_CHANGED, handleMoveChanged);
    GameReplayService.on(ReplayEvent.REPLAY_STARTED, handleReplayStarted);
    GameReplayService.on(ReplayEvent.REPLAY_PAUSED, handleReplayPaused);
    GameReplayService.on(ReplayEvent.REPLAY_COMPLETED, handleReplayCompleted);
    
    // Clean up event listeners
    return () => {
      GameReplayService.off(ReplayEvent.MOVE_CHANGED, handleMoveChanged);
      GameReplayService.off(ReplayEvent.REPLAY_STARTED, handleReplayStarted);
      GameReplayService.off(ReplayEvent.REPLAY_PAUSED, handleReplayPaused);
      GameReplayService.off(ReplayEvent.REPLAY_COMPLETED, handleReplayCompleted);
      
      // Stop the replay when the component unmounts
      GameReplayService.stopReplay();
    };
  }, []);
  
  // Handle play/pause button press
  const handlePlayPause = () => {
    if (isPlaying) {
      GameReplayService.pauseReplay();
    } else {
      GameReplayService.startReplay();
    }
  };
  
  // Handle previous button press
  const handlePrevious = () => {
    GameReplayService.previousMove();
  };
  
  // Handle next button press
  const handleNext = () => {
    GameReplayService.nextMove();
  };
  
  // Handle slider change
  const handleSliderChange = (value: number) => {
    GameReplayService.goToMove(Math.round(value));
  };
  
  // Handle speed change
  const handleSpeedChange = (value: number) => {
    setReplaySpeed(value);
    GameReplayService.setReplaySpeed(value);
  };
  
  // Format move notation
  const formatMove = (move: any, index: number) => {
    if (!move) return '';
    
    const { from, to, piece } = move;
    return `${Math.floor(index / 2) + 1}${index % 2 === 0 ? '.' : '...'} ${piece}${from.col}${from.row}-${to.col}${to.row}`;
  };
  
  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        
        <Text style={styles.title}>Game Replay</Text>
        
        <View style={styles.placeholder} />
      </View>
      
      {isLoading || !currentGame ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#f4511e" />
          <Text style={styles.loadingText}>Loading game...</Text>
        </View>
      ) : (
        <View style={styles.content}>
          <View style={styles.gameInfo}>
            <Text style={styles.gameDate}>{formatDate(currentGame.date)}</Text>
            <Text style={styles.gameDetails}>
              {currentGame.playerColor === 'red' ? 'Red' : 'Black'} vs {currentGame.opponent} ({currentGame.result === 'win' ? 'Win' : currentGame.result === 'loss' ? 'Loss' : 'Draw'})
            </Text>
          </View>
          
          <View style={styles.boardContainer}>
            <ChessBoard />
          </View>
          
          <View style={styles.controlsContainer}>
            <View style={styles.sliderContainer}>
              <Text style={styles.moveText}>
                Move: {currentMoveIndex + 1}/{totalMoves}
              </Text>
              <Slider
                style={styles.slider}
                minimumValue={-1}
                maximumValue={totalMoves - 1}
                value={currentMoveIndex}
                onValueChange={handleSliderChange}
                minimumTrackTintColor="#f4511e"
                maximumTrackTintColor="#d3d3d3"
                thumbTintColor="#f4511e"
                step={1}
              />
            </View>
            
            <View style={styles.buttonsContainer}>
              <TouchableOpacity
                style={styles.controlButton}
                onPress={handlePrevious}
                disabled={currentMoveIndex <= -1}
              >
                <Icon
                  name="skip-previous"
                  size={24}
                  color={currentMoveIndex <= -1 ? '#ccc' : '#333'}
                />
              </TouchableOpacity>
              
              <TouchableOpacity
                style={styles.playButton}
                onPress={handlePlayPause}
              >
                <Icon
                  name={isPlaying ? 'pause' : 'play-arrow'}
                  size={32}
                  color="#fff"
                />
              </TouchableOpacity>
              
              <TouchableOpacity
                style={styles.controlButton}
                onPress={handleNext}
                disabled={currentMoveIndex >= totalMoves - 1}
              >
                <Icon
                  name="skip-next"
                  size={24}
                  color={currentMoveIndex >= totalMoves - 1 ? '#ccc' : '#333'}
                />
              </TouchableOpacity>
            </View>
            
            <View style={styles.speedContainer}>
              <Text style={styles.speedText}>Speed:</Text>
              <Slider
                style={styles.speedSlider}
                minimumValue={200}
                maximumValue={3000}
                value={replaySpeed}
                onValueChange={handleSpeedChange}
                minimumTrackTintColor="#f4511e"
                maximumTrackTintColor="#d3d3d3"
                thumbTintColor="#f4511e"
                step={100}
              />
              <Text style={styles.speedValue}>{replaySpeed / 1000}s</Text>
            </View>
          </View>
          
          <View style={styles.movesContainer}>
            <Text style={styles.movesTitle}>Moves:</Text>
            <ScrollView style={styles.movesList}>
              {currentGame.moves.map((move, index) => (
                <TouchableOpacity
                  key={index}
                  style={[
                    styles.moveItem,
                    index === currentMoveIndex && styles.currentMoveItem,
                  ]}
                  onPress={() => handleSliderChange(index)}
                >
                  <Text
                    style={[
                      styles.moveText,
                      index === currentMoveIndex && styles.currentMoveText,
                    ]}
                  >
                    {formatMove(move, index)}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        </View>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButton: {
    padding: 8,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  placeholder: {
    width: 40,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  gameInfo: {
    marginBottom: 16,
  },
  gameDate: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
  },
  gameDetails: {
    fontSize: 12,
    color: '#666',
  },
  boardContainer: {
    alignItems: 'center',
    marginBottom: 16,
  },
  controlsContainer: {
    marginBottom: 16,
  },
  sliderContainer: {
    marginBottom: 16,
  },
  moveText: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  buttonsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  controlButton: {
    padding: 12,
  },
  playButton: {
    backgroundColor: '#f4511e',
    borderRadius: 30,
    width: 60,
    height: 60,
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 20,
  },
  speedContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  speedText: {
    fontSize: 12,
    color: '#666',
    width: 50,
  },
  speedSlider: {
    flex: 1,
    height: 40,
  },
  speedValue: {
    fontSize: 12,
    color: '#666',
    width: 30,
    textAlign: 'right',
  },
  movesContainer: {
    flex: 1,
  },
  movesTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  movesList: {
    flex: 1,
    backgroundColor: '#fff',
    borderRadius: 8,
    padding: 8,
  },
  moveItem: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 4,
  },
  currentMoveItem: {
    backgroundColor: '#e3f2fd',
  },
  currentMoveText: {
    fontWeight: 'bold',
    color: '#2196f3',
  },
});

export default GameReplayScreen;
