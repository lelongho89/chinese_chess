import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { useAppSelector } from '../../hooks';
import Piece from './Piece';
import { 
  DEFAULT_PIECE_SIZE,
  DEFAULT_BOARD_WIDTH,
  DEFAULT_BOARD_HEIGHT,
  getCellSize,
  getPositionFromCoordinates
} from '../../constants';
import { ChessPiece } from '../../store/slices/gameSlice';

/**
 * Props for the PieceContainer component
 */
interface PieceContainerProps {
  piece: ChessPiece;
  boardWidth: number;
  boardHeight: number;
  isSelected?: boolean;
  isLastMove?: boolean;
  onPress?: (piece: ChessPiece) => void;
  flipped?: boolean;
}

/**
 * PieceContainer component for the Chinese Chess game
 * This component handles the positioning and interaction of a piece
 */
const PieceContainer: React.FC<PieceContainerProps> = ({ 
  piece, 
  boardWidth, 
  boardHeight,
  isSelected = false,
  isLastMove = false,
  onPress,
  flipped = false
}) => {
  // Get the scale from Redux store
  const scale = useAppSelector(state => state.game.scale);
  
  // Calculate the cell size
  const cellSize = getCellSize(boardWidth);
  
  // Calculate the piece size based on the cell size
  const pieceSize = cellSize * 0.9;
  
  // Get the position of the piece
  const { row, col } = piece.position;
  
  // Calculate the position on the board
  let { x, y } = getPositionFromCoordinates(row, col, cellSize, boardWidth, boardHeight);
  
  // Adjust position for flipped board
  if (flipped) {
    x = boardWidth - x;
    y = boardHeight - y;
  }
  
  // Calculate the position offset to center the piece
  const offset = pieceSize / 2;
  
  // Handle piece press
  const handlePress = () => {
    if (onPress) {
      onPress(piece);
    }
  };
  
  return (
    <TouchableOpacity
      style={[
        styles.container,
        {
          left: x - offset,
          top: y - offset,
          width: pieceSize,
          height: pieceSize,
        }
      ]}
      onPress={handlePress}
      activeOpacity={0.7}
    >
      <Piece
        type={piece.type}
        size={pieceSize}
        isSelected={isSelected}
        isLastMove={isLastMove}
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

export default PieceContainer;
