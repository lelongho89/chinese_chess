import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useAppSelector } from '../../hooks';
import MoveIndicator from './MoveIndicator';
import { 
  DEFAULT_PIECE_SIZE,
  DEFAULT_BOARD_WIDTH,
  DEFAULT_BOARD_HEIGHT,
  getCellSize,
  getPositionFromCoordinates
} from '../../constants';

/**
 * Props for the MoveIndicatorContainer component
 */
interface MoveIndicatorContainerProps {
  position: { row: number; col: number };
  boardWidth: number;
  boardHeight: number;
  onPress?: (position: { row: number; col: number }) => void;
  flipped?: boolean;
}

/**
 * MoveIndicatorContainer component for the Chinese Chess game
 * This component handles the positioning and interaction of a move indicator
 */
const MoveIndicatorContainer: React.FC<MoveIndicatorContainerProps> = ({ 
  position, 
  boardWidth, 
  boardHeight,
  onPress,
  flipped = false
}) => {
  // Get the scale from Redux store
  const scale = useAppSelector(state => state.game.scale);
  
  // Calculate the cell size
  const cellSize = getCellSize(boardWidth);
  
  // Calculate the indicator size based on the cell size
  const indicatorSize = cellSize * 0.7;
  
  // Get the position of the indicator
  const { row, col } = position;
  
  // Calculate the position on the board
  let { x, y } = getPositionFromCoordinates(row, col, cellSize, boardWidth, boardHeight);
  
  // Adjust position for flipped board
  if (flipped) {
    x = boardWidth - x;
    y = boardHeight - y;
  }
  
  // Calculate the position offset to center the indicator
  const offset = indicatorSize / 2;
  
  // Handle indicator press
  const handlePress = () => {
    if (onPress) {
      onPress(position);
    }
  };
  
  return (
    <TouchableOpacity
      style={[
        styles.container,
        {
          left: x - offset,
          top: y - offset,
          width: indicatorSize,
          height: indicatorSize,
        }
      ]}
      onPress={handlePress}
      activeOpacity={0.7}
    >
      <MoveIndicator
        size={indicatorSize}
        scale={scale}
      />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default MoveIndicatorContainer;
