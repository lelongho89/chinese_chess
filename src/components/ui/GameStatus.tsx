import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useAppSelector } from '../../hooks';

/**
 * Props for the GameStatus component
 */
interface GameStatusProps {
  isCheck?: boolean;
  isCheckmate?: boolean;
}

/**
 * GameStatus component for the Chinese Chess game
 * This component displays the current game status (check, checkmate, etc.)
 */
const GameStatus: React.FC<GameStatusProps> = ({ 
  isCheck,
  isCheckmate
}) => {
  // Get state from Redux store
  const currentPlayer = useAppSelector(state => state.game.currentPlayer);
  const history = useAppSelector(state => state.game.history);
  const lastMove = history.length > 0 ? history[history.length - 1] : null;
  
  // If no status is provided, don't render anything
  if (!isCheck && !isCheckmate && !lastMove) {
    return null;
  }
  
  return (
    <View style={styles.container}>
      {isCheckmate && (
        <Text style={styles.checkmateText}>
          Checkmate! {currentPlayer === 'red' ? 'Black' : 'Red'} wins!
        </Text>
      )}
      
      {isCheck && !isCheckmate && (
        <Text style={styles.checkText}>
          Check! {currentPlayer}'s general is in danger!
        </Text>
      )}
      
      {lastMove && !isCheckmate && (
        <Text style={styles.moveText}>
          Last move: {lastMove.piece} from ({lastMove.from.row}, {lastMove.from.col}) to ({lastMove.to.row}, {lastMove.to.col})
          {lastMove.capturedPiece && ` captured ${lastMove.capturedPiece}`}
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.05)',
    borderRadius: 4,
    margin: 8,
  },
  checkmateText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#d32f2f',
    textAlign: 'center',
  },
  checkText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#f57c00',
    textAlign: 'center',
  },
  moveText: {
    fontSize: 12,
    color: '#333',
    textAlign: 'center',
  },
});

export default GameStatus;
