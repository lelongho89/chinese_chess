import React from 'react';
import { View, Image, StyleSheet, ImageSourcePropType } from 'react-native';
import { useAppSelector } from '../../hooks';
import { 
  DEFAULT_PIECE_SIZE,
  getPieceColor,
  getPieceName,
  getPieceImage,
  SKIN_TYPES
} from '../../constants';

/**
 * Props for the Piece component
 */
interface PieceProps {
  type: string;
  size?: number;
  isSelected?: boolean;
  isLastMove?: boolean;
  scale?: number;
}

/**
 * Piece component for the Chinese Chess game
 */
const Piece: React.FC<PieceProps> = ({ 
  type, 
  size = DEFAULT_PIECE_SIZE, 
  isSelected = false,
  isLastMove = false,
  scale = 1
}) => {
  // Get the current skin from Redux store
  const skinType = useAppSelector(state => state.game.skin);
  
  // Get the piece color
  const color = getPieceColor(type);
  
  // Get the piece name
  const name = getPieceName(type);
  
  // Calculate the actual size based on the scale
  const actualSize = size * scale;
  
  // Get the piece image
  const pieceImage = getPieceImage(skinType || SKIN_TYPES.WOODS, type) as ImageSourcePropType;
  
  // Get the selected indicator image if needed
  const selectedImage = isSelected ? 
    require('../../assets/skins/woods/selected.png') as ImageSourcePropType : 
    null;
  
  // Get the last move indicator image if needed
  const lastMoveImage = isLastMove ? 
    require('../../assets/skins/woods/last_move.png') as ImageSourcePropType : 
    null;
  
  return (
    <View style={[styles.container, { width: actualSize, height: actualSize }]}>
      {/* Last move indicator */}
      {lastMoveImage && (
        <Image
          source={lastMoveImage}
          style={[styles.indicator, { width: actualSize, height: actualSize }]}
          resizeMode="contain"
        />
      )}
      
      {/* Piece image */}
      <Image
        source={pieceImage}
        style={[styles.piece, { width: actualSize, height: actualSize }]}
        resizeMode="contain"
      />
      
      {/* Selected indicator */}
      {selectedImage && (
        <Image
          source={selectedImage}
          style={[styles.indicator, { width: actualSize, height: actualSize }]}
          resizeMode="contain"
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    justifyContent: 'center',
    alignItems: 'center',
  },
  piece: {
    position: 'absolute',
  },
  indicator: {
    position: 'absolute',
  },
});

export default Piece;
