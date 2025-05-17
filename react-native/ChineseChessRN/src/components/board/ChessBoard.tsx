import React, { useState, useEffect, useCallback, memo, useMemo } from 'react';
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
import { useRenderTime, useStableCallback } from '../../utils/performance';

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
const ChessBoard: React.FC<ChessBoardProps> = memo(({
  width: propWidth,
  height: propHeight,
  onCellPress,
  onPiecePress,
  onMovePress
}) => {
  // Track render time in development
  useRenderTime('ChessBoard');

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

  // Handle board press (background) - memoized to prevent unnecessary re-renders
  const handleBoardPress = useCallback((event: any) => {
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
  }, [dispatch, onCellPress, cellSize, dimensions.width, dimensions.height]);

  // Handle piece press - memoized to prevent unnecessary re-renders
  const handlePiecePress = useStableCallback((piece: ChessPiece) => {
    if (onPiecePress) {
      onPiecePress(piece);
    }
  });

  // Handle move press - memoized to prevent unnecessary re-renders
  const handleMovePress = useStableCallback((position: { row: number; col: number }) => {
    if (onMovePress) {
      onMovePress(position);
    }
  });

  // Update dimensions when the screen size changes - memoized to prevent unnecessary re-renders
  const updateDimensions = useCallback(() => {
    const newScreenWidth = Dimensions.get('window').width;
    const newScreenHeight = Dimensions.get('window').height;

    const newWidth = propWidth || Math.min(newScreenWidth - 40, DEFAULT_BOARD_WIDTH);
    const newHeight = propHeight || 0; // Will be calculated based on aspect ratio

    setDimensions({ width: newWidth, height: newHeight });
  }, [propWidth, propHeight]);

  useEffect(() => {
    // Add event listener for dimension changes
    const subscription = Dimensions.addEventListener('change', updateDimensions);

    // Clean up
    return () => {
      // Modern way to remove event listener in React Native
      subscription.remove();
    };
  }, [updateDimensions]);

  // Calculate the actual height
  const actualHeight = dimensions.height || DEFAULT_BOARD_HEIGHT * (dimensions.width / DEFAULT_BOARD_WIDTH);

  // Memoize the board components to prevent unnecessary re-renders
  const boardComponent = useMemo(() => (
    <Board
      width={dimensions.width}
      height={dimensions.height}
      flipped={isFlipped}
    />
  ), [dimensions.width, dimensions.height, isFlipped]);

  const boardGridComponent = useMemo(() => (
    <BoardGrid
      width={dimensions.width}
      height={actualHeight}
      flipped={isFlipped}
    />
  ), [dimensions.width, actualHeight, isFlipped]);

  const piecesLayerComponent = useMemo(() => (
    <PiecesLayer
      boardWidth={dimensions.width}
      boardHeight={actualHeight}
      onPiecePress={handlePiecePress}
      onMovePress={handleMovePress}
    />
  ), [dimensions.width, actualHeight, handlePiecePress, handleMovePress]);

  return (
    <TouchableWithoutFeedback onPress={handleBoardPress} testID="chess-board">
      <View style={[styles.container, { width: dimensions.width, height: actualHeight }]}>
        {boardComponent}
        {boardGridComponent}
        {piecesLayerComponent}
      </View>
    </TouchableWithoutFeedback>
  );
});

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
});

export default ChessBoard;
