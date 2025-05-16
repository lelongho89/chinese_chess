import React from 'react';
import { View, StyleSheet } from 'react-native';
import { useAppSelector } from '../../hooks';
import PieceContainer from './PieceContainer';
import MoveIndicatorContainer from './MoveIndicatorContainer';
import { ChessPiece } from '../../store/slices/gameSlice';

/**
 * Props for the PiecesLayer component
 */
interface PiecesLayerProps {
  boardWidth: number;
  boardHeight: number;
  onPiecePress?: (piece: ChessPiece) => void;
  onMovePress?: (position: { row: number; col: number }) => void;
}

/**
 * PiecesLayer component for the Chinese Chess game
 * This component renders all the pieces and move indicators on the board
 */
const PiecesLayer: React.FC<PiecesLayerProps> = ({ 
  boardWidth, 
  boardHeight,
  onPiecePress,
  onMovePress
}) => {
  // Get the pieces, selected piece, possible moves, and last move from Redux store
  const pieces = useAppSelector(state => state.game.pieces);
  const selectedPiece = useAppSelector(state => state.game.selectedPiece);
  const possibleMoves = useAppSelector(state => state.game.possibleMoves);
  const history = useAppSelector(state => state.game.history);
  const lastMove = history.length > 0 ? history[history.length - 1] : null;
  
  // Get the board orientation from Redux store
  const boardOrientation = useAppSelector(state => state.settings.boardOrientation);
  const isFlipped = boardOrientation === 'flipped';
  
  return (
    <View style={[styles.container, { width: boardWidth, height: boardHeight }]}>
      {/* Render possible move indicators */}
      {selectedPiece && possibleMoves.map((move, index) => (
        <MoveIndicatorContainer
          key={`move-${index}`}
          position={move}
          boardWidth={boardWidth}
          boardHeight={boardHeight}
          onPress={onMovePress}
          flipped={isFlipped}
        />
      ))}
      
      {/* Render pieces */}
      {pieces.map(piece => (
        <PieceContainer
          key={piece.id}
          piece={piece}
          boardWidth={boardWidth}
          boardHeight={boardHeight}
          isSelected={selectedPiece?.id === piece.id}
          isLastMove={
            lastMove && 
            ((lastMove.from.row === piece.position.row && lastMove.from.col === piece.position.col) ||
             (lastMove.to.row === piece.position.row && lastMove.to.col === piece.position.col))
          }
          onPress={onPiecePress}
          flipped={isFlipped}
        />
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
});

export default PiecesLayer;
