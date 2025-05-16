import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Dimensions, TouchableWithoutFeedback } from 'react-native';
import { useAppSelector, useAppDispatch } from '../../hooks';
import Board from './Board';
import BoardGrid from './BoardGrid';
import { PiecesLayer } from '../pieces';
import {
  DEFAULT_BOARD_WIDTH,
  DEFAULT_BOARD_HEIGHT,
  getCellSize,
  getCoordinatesFromPosition,
  getPositionFromCoordinates
} from '../../constants';
import { ChessPiece, setSelectedPiece } from '../../store/slices/gameSlice';

/**
 * Props for the ChessBoard component
 */
interface ChessBoardProps {
  width?: number;
  height?: number;
  onCellPress?: (row: number, col: number) => void;
  onPiecePress?: (piece: ChessPiece) => void;
  onMovePress?: (position: { row: number; col: number }) => void;
}

/**
 * ChessBoard component for the Chinese Chess game
 * This component combines the Board, BoardGrid, and PiecesLayer components
 */
const ChessBoard: React.FC<ChessBoardProps> = ({
  width: propWidth,
  height: propHeight,
  onCellPress,
  onPiecePress,
  onMovePress
}) => {
  const dispatch = useAppDispatch();

  // Get the screen dimensions
  const screenWidth = Dimensions.get('window').width;
  const screenHeight = Dimensions.get('window').height;

  // Calculate the board width and height based on the screen size
  const [dimensions, setDimensions] = useState({
    width: propWidth || Math.min(screenWidth - 40, DEFAULT_BOARD_WIDTH),
    height: propHeight || 0 // Will be calculated based on aspect ratio
  });

  // Get the board orientation from Redux store
  const boardOrientation = useAppSelector(state => state.settings.boardOrientation);
  const isFlipped = boardOrientation === 'flipped';

  // Calculate the cell size
  const cellSize = getCellSize(dimensions.width);

  // Handle board press (background)
  const handleBoardPress = (event: any) => {
    // Deselect the current piece when clicking on the board background
    dispatch(setSelectedPiece(null));

    if (!onCellPress) return;

    // Get the press position relative to the board
    const { locationX, locationY } = event.nativeEvent;

    // Convert the position to board coordinates
    const { row, col } = getCoordinatesFromPosition(
      locationX,
      locationY,
      cellSize,
      dimensions.width,
      dimensions.height || DEFAULT_BOARD_HEIGHT
    );

    // Check if the coordinates are within the board bounds
    if (row >= 0 && row < 10 && col >= 0 && col < 9) {
      onCellPress(row, col);
    }
  };

  // Handle piece press
  const handlePiecePress = (piece: ChessPiece) => {
    if (onPiecePress) {
      onPiecePress(piece);
    }
  };

  // Handle move press
  const handleMovePress = (position: { row: number; col: number }) => {
    if (onMovePress) {
      onMovePress(position);
    }
  };

  // Update dimensions when the screen size changes
  useEffect(() => {
    const updateDimensions = () => {
      const newScreenWidth = Dimensions.get('window').width;
      const newScreenHeight = Dimensions.get('window').height;

      const newWidth = propWidth || Math.min(newScreenWidth - 40, DEFAULT_BOARD_WIDTH);
      const newHeight = propHeight || 0; // Will be calculated based on aspect ratio

      setDimensions({ width: newWidth, height: newHeight });
    };

    // Add event listener for dimension changes
    Dimensions.addEventListener('change', updateDimensions);

    // Clean up
    return () => {
      // Remove event listener
      // Note: This is the old way, in newer React Native versions you would use the returned subscription
      // Dimensions.removeEventListener('change', updateDimensions);
    };
  }, [propWidth, propHeight]);

  // Calculate the actual height
  const actualHeight = dimensions.height || DEFAULT_BOARD_HEIGHT * (dimensions.width / DEFAULT_BOARD_WIDTH);

  return (
    <TouchableWithoutFeedback onPress={handleBoardPress}>
      <View style={[styles.container, { width: dimensions.width, height: actualHeight }]}>
        <Board
          width={dimensions.width}
          height={dimensions.height}
          flipped={isFlipped}
        />
        <BoardGrid
          width={dimensions.width}
          height={actualHeight}
          flipped={isFlipped}
        />
        <PiecesLayer
          boardWidth={dimensions.width}
          boardHeight={actualHeight}
          onPiecePress={handlePiecePress}
          onMovePress={handleMovePress}
        />
      </View>
    </TouchableWithoutFeedback>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
});

export default ChessBoard;
