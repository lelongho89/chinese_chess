import React, { useEffect, useState } from 'react';
import { View, StyleSheet, SafeAreaView, StatusBar } from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { GameScreenRouteProp, GameScreenNavigationProp } from '../navigation/types';
import { ChessBoard } from '../components/board';
import {
  GameHeader,
  GameBottomBar,
  GameStatus,
  PlayerInfo,
  GameOptionsModal,
  AIThinkingIndicator
} from '../components/ui';
import { GameTimerDisplay } from '../components/timer';
import { useAppDispatch, useAppSelector } from '../hooks';
import { useLocalization } from '../hooks/useLocalization';
import { ChessPiece } from '../store/slices/gameSlice';
import { initGame, selectPiece, movePiece } from '../store/actions';
import GameService from '../services/game/GameService';

/**
 * Game screen component for the Chinese Chess application
 */
const GameScreen: React.FC = () => {
  const route = useRoute<GameScreenRouteProp>();
  const navigation = useNavigation<GameScreenNavigationProp>();
  const dispatch = useAppDispatch();
  const { gameMode } = route.params;

  // State for options modal
  const [optionsModalVisible, setOptionsModalVisible] = useState(false);

  // State for AI thinking
  const [aiThinking, setAIThinking] = useState(false);
  const [aiDifficulty, setAIDifficulty] = useState<'easy' | 'medium' | 'hard'>('medium');

  // Get state from Redux store
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  const selectedPiece = useAppSelector(state => state.game.selectedPiece);
  const history = useAppSelector(state => state.game.history);
  const isGameActive = useAppSelector(state => state.game.isGameActive);
  const aiDifficultyFromSettings = useAppSelector(state => state.settings.aiDifficulty);

  // Initialize the game when the component mounts
  useEffect(() => {
    dispatch(initGame({ gameMode }));

    // Set up AI difficulty from settings
    if (gameMode === 'ai') {
      GameService.setAIDifficulty(aiDifficultyFromSettings as any);
      setAIDifficulty(aiDifficultyFromSettings as any);
    }
  }, [dispatch, gameMode, aiDifficultyFromSettings]);

  // Set up event listeners for AI thinking
  useEffect(() => {
    if (gameMode === 'ai') {
      // Add event listener for AI thinking
      const handleAIThinking = (event: string, data: any) => {
        if (event === 'aiThinking') {
          setAIThinking(data.thinking);
          if (data.difficulty) {
            setAIDifficulty(data.difficulty);
          }
        }
      };

      // Add the event listener
      const removeListener = GameService.addListener(handleAIThinking);

      // Clean up the event listener when the component unmounts
      return () => {
        removeListener();
      };
    }
  }, [gameMode]);

  // Handle cell press
  const handleCellPress = (row: number, col: number) => {
    console.log(`Cell pressed: row=${row}, col=${col}`);
    // Deselect the current piece
    dispatch(selectPiece(null));
  };

  // Handle piece press
  const handlePiecePress = (piece: ChessPiece) => {
    console.log(`Piece pressed:`, piece);

    // Check if it's the player's turn
    if (piece.color !== currentPlayer) {
      console.log(`Not your turn. Current player: ${currentPlayer}`);
      return;
    }

    // Select the piece and get valid moves
    dispatch(selectPiece(piece));
  };

  // Handle move press
  const handleMovePress = (position: { row: number; col: number }) => {
    console.log(`Move pressed:`, position);

    if (selectedPiece) {
      // Move the piece
      dispatch(movePiece(selectedPiece.position, position));
    }
  };

  // Handle settings press
  const handleSettingsPress = () => {
    setOptionsModalVisible(true);
  };

  // Handle undo press
  const handleUndoPress = () => {
    // TODO: Implement undo functionality
    console.log('Undo pressed');
  };

  // Handle restart press
  const handleRestartPress = () => {
    dispatch(initGame({ gameMode }));
  };

  // Handle hint press
  const handleHintPress = () => {
    // TODO: Implement hint functionality
    console.log('Hint pressed');
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#f5f5f5" />

      <GameHeader onSettingsPress={handleSettingsPress} />

      <View style={styles.playersContainer}>
        <PlayerInfo
          color="black"
          name="Black Player"
          isCurrentPlayer={currentPlayer === 'black'}
          capturedPieces={[]}
        />
      </View>

      {/* Game timer display */}
      <GameTimerDisplay />

      <GameStatus />

      {/* AI thinking indicator */}
      {gameMode === 'ai' && (
        <AIThinkingIndicator isThinking={aiThinking} difficulty={aiDifficulty} />
      )}

      <View style={styles.gameBoard}>
        <ChessBoard
          onCellPress={handleCellPress}
          onPiecePress={handlePiecePress}
          onMovePress={handleMovePress}
        />
      </View>

      <View style={styles.playersContainer}>
        <PlayerInfo
          color="red"
          name="Red Player"
          isCurrentPlayer={currentPlayer === 'red'}
          capturedPieces={[]}
        />
      </View>

      <GameBottomBar
        onUndoPress={handleUndoPress}
        onRestartPress={handleRestartPress}
        onHintPress={handleHintPress}
      />

      <GameOptionsModal
        visible={optionsModalVisible}
        onClose={() => setOptionsModalVisible(false)}
        gameMode={gameMode}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  playersContainer: {
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  gameBoard: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    margin: 10,
  },
});

export default GameScreen;
