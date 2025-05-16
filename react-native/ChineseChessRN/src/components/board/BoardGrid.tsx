import React from 'react';
import { View, StyleSheet } from 'react-native';
import { 
  BOARD_ROWS, 
  BOARD_COLS, 
  BOARD_PADDING,
  DEFAULT_BOARD_WIDTH,
  DEFAULT_BOARD_HEIGHT,
  getCellSize,
  getPositionFromCoordinates
} from '../../constants';

/**
 * Props for the BoardGrid component
 */
interface BoardGridProps {
  width: number;
  height: number;
  flipped?: boolean;
  showGrid?: boolean;
}

/**
 * BoardGrid component for the Chinese Chess game
 * This component renders the grid lines on the board
 */
const BoardGrid: React.FC<BoardGridProps> = ({ 
  width, 
  height, 
  flipped = false,
  showGrid = true
}) => {
  if (!showGrid) return null;
  
  // Calculate the cell size
  const cellSize = getCellSize(width);
  
  // Generate horizontal grid lines
  const horizontalLines = [];
  for (let row = 0; row < BOARD_ROWS; row++) {
    const { x: startX, y } = getPositionFromCoordinates(row, 0, cellSize, width, height);
    const { x: endX } = getPositionFromCoordinates(row, BOARD_COLS - 1, cellSize, width, height);
    
    horizontalLines.push(
      <View
        key={`h-${row}`}
        style={[
          styles.gridLine,
          styles.horizontalLine,
          {
            left: startX,
            top: y,
            width: endX - startX,
            height: 1,
            transform: flipped ? [{ rotate: '180deg' }] : []
          }
        ]}
      />
    );
  }
  
  // Generate vertical grid lines
  const verticalLines = [];
  for (let col = 0; col < BOARD_COLS; col++) {
    const { x, y: startY } = getPositionFromCoordinates(0, col, cellSize, width, height);
    const { y: endY } = getPositionFromCoordinates(BOARD_ROWS - 1, col, cellSize, width, height);
    
    // For the middle columns (3-5), we need to split the lines at the river
    if (col >= 3 && col <= 5) {
      // Top palace vertical lines
      verticalLines.push(
        <View
          key={`v-${col}-top`}
          style={[
            styles.gridLine,
            styles.verticalLine,
            {
              left: x,
              top: startY,
              width: 1,
              height: cellSize * 2,
              transform: flipped ? [{ rotate: '180deg' }] : []
            }
          ]}
        />
      );
      
      // Bottom palace vertical lines
      verticalLines.push(
        <View
          key={`v-${col}-bottom`}
          style={[
            styles.gridLine,
            styles.verticalLine,
            {
              left: x,
              top: endY - cellSize * 2,
              width: 1,
              height: cellSize * 2,
              transform: flipped ? [{ rotate: '180deg' }] : []
            }
          ]}
        />
      );
    } else {
      // Full vertical lines for other columns
      verticalLines.push(
        <View
          key={`v-${col}`}
          style={[
            styles.gridLine,
            styles.verticalLine,
            {
              left: x,
              top: startY,
              width: 1,
              height: endY - startY,
              transform: flipped ? [{ rotate: '180deg' }] : []
            }
          ]}
        />
      );
    }
  }
  
  // Generate diagonal lines for the palaces
  const diagonalLines = [];
  
  // Top palace diagonals
  diagonalLines.push(
    <View
      key="d-top-1"
      style={[
        styles.gridLine,
        styles.diagonalLine,
        {
          width: cellSize * 2 * Math.sqrt(2),
          height: 1,
          left: BOARD_PADDING.LEFT + 3 * cellSize,
          top: BOARD_PADDING.TOP + 0 * cellSize,
          transform: [
            { rotate: '45deg' },
            { translateY: cellSize },
            ...(flipped ? [{ rotate: '180deg' }] : [])
          ]
        }
      ]}
    />
  );
  
  diagonalLines.push(
    <View
      key="d-top-2"
      style={[
        styles.gridLine,
        styles.diagonalLine,
        {
          width: cellSize * 2 * Math.sqrt(2),
          height: 1,
          left: BOARD_PADDING.LEFT + 3 * cellSize,
          top: BOARD_PADDING.TOP + 2 * cellSize,
          transform: [
            { rotate: '-45deg' },
            { translateY: -cellSize },
            ...(flipped ? [{ rotate: '180deg' }] : [])
          ]
        }
      ]}
    />
  );
  
  // Bottom palace diagonals
  diagonalLines.push(
    <View
      key="d-bottom-1"
      style={[
        styles.gridLine,
        styles.diagonalLine,
        {
          width: cellSize * 2 * Math.sqrt(2),
          height: 1,
          left: BOARD_PADDING.LEFT + 3 * cellSize,
          top: BOARD_PADDING.TOP + 7 * cellSize,
          transform: [
            { rotate: '45deg' },
            { translateY: cellSize },
            ...(flipped ? [{ rotate: '180deg' }] : [])
          ]
        }
      ]}
    />
  );
  
  diagonalLines.push(
    <View
      key="d-bottom-2"
      style={[
        styles.gridLine,
        styles.diagonalLine,
        {
          width: cellSize * 2 * Math.sqrt(2),
          height: 1,
          left: BOARD_PADDING.LEFT + 3 * cellSize,
          top: BOARD_PADDING.TOP + 9 * cellSize,
          transform: [
            { rotate: '-45deg' },
            { translateY: -cellSize },
            ...(flipped ? [{ rotate: '180deg' }] : [])
          ]
        }
      ]}
    />
  );
  
  return (
    <View style={[styles.container, { width, height }]}>
      {horizontalLines}
      {verticalLines}
      {diagonalLines}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  gridLine: {
    position: 'absolute',
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  horizontalLine: {
    height: 1,
  },
  verticalLine: {
    width: 1,
  },
  diagonalLine: {
    height: 1,
    transformOrigin: 'center',
  },
});

export default BoardGrid;
