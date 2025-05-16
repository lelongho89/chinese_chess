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
  GameOptionsModal
} from '../components/ui';
import { useAppDispatch, useAppSelector } from '../hooks';
import { ChessPiece } from '../store/slices/gameSlice';
import { initGame, selectPiece, movePiece } from '../store/actions';

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

  // Get state from Redux store
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  const selectedPiece = useAppSelector(state => state.game.selectedPiece);
  const history = useAppSelector(state => state.game.history);
  const isGameActive = useAppSelector(state => state.game.isGameActive);

  // Initialize the game when the component mounts
  useEffect(() => {
    dispatch(initGame({ gameMode }));
  }, [dispatch, gameMode]);

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

      <GameStatus />

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
