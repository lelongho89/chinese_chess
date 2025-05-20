import React, { memo, useMemo } from 'react';
import { View, Image, StyleSheet, ImageSourcePropType } from 'react-native';
import { useAppSelector } from '../../hooks';
import {
  DEFAULT_PIECE_SIZE,
  getPieceColor,
  getPieceName,
  getPieceImage,
  SKIN_TYPES
} from '../../constants';
import { useRenderTime } from '../../utils/performance';

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
 * Memoized to prevent unnecessary re-renders
 */
const Piece: React.FC<PieceProps> = memo(({
  type,
  size = DEFAULT_PIECE_SIZE,
  isSelected = false,
  isLastMove = false,
  scale = 1
}) => {
  // Track render time in development
  if (__DEV__) {
    useRenderTime('Piece');
  }

  // Get the current skin from Redux store
  const skinType = useAppSelector(state => state.game.skin);

  // Get the piece color
  const color = getPieceColor(type);

  // Get the piece name
  const name = getPieceName(type);

  // Calculate the actual size based on the scale
  const actualSize = size * scale;

  // Memoize the piece image to prevent unnecessary re-renders
  const pieceImage = useMemo(() =>
    getPieceImage(skinType || SKIN_TYPES.WOODS, type) as ImageSourcePropType,
    [skinType, type]
  );

  // Memoize the selected indicator image
  const selectedImage = useMemo(() =>
    isSelected ? require('../../assets/skins/woods/selected.png') as ImageSourcePropType : null,
    [isSelected]
  );

  // Memoize the last move indicator image
  const lastMoveImage = useMemo(() =>
    isLastMove ? require('../../assets/skins/woods/last_move.png') as ImageSourcePropType : null,
    [isLastMove]
  );

  // Memoize the container style
  const containerStyle = useMemo(() =>
    [styles.container, { width: actualSize, height: actualSize }],
    [actualSize]
  );

  // Memoize the image style
  const imageStyle = useMemo(() =>
    [styles.piece, { width: actualSize, height: actualSize }],
    [actualSize]
  );

  // Memoize the indicator style
  const indicatorStyle = useMemo(() =>
    [styles.indicator, { width: actualSize, height: actualSize }],
    [actualSize]
  );

  return (
    <View style={containerStyle} testID={`chess-piece-${type}`}>
      {/* Last move indicator */}
      {lastMoveImage && (
        <Image
          source={lastMoveImage}
          style={indicatorStyle}
          resizeMode="contain"
        />
      )}

      {/* Piece image */}
      <Image
        source={pieceImage}
        style={imageStyle}
        resizeMode="contain"
      />

      {/* Selected indicator */}
      {selectedImage && (
        <Image
          source={selectedImage}
          style={indicatorStyle}
          resizeMode="contain"
        />
      )}
    </View>
  );
});

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
