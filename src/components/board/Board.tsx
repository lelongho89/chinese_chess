import React from 'react';
import { View, Image, StyleSheet, Dimensions, ImageSourcePropType } from 'react-native';
import { useAppSelector } from '../../hooks';
import { 
  DEFAULT_BOARD_WIDTH, 
  DEFAULT_BOARD_HEIGHT,
  BOARD_PADDING,
  getSkin,
  SKIN_TYPES
} from '../../constants';

/**
 * Props for the Board component
 */
interface BoardProps {
  width?: number;
  height?: number;
  flipped?: boolean;
}

/**
 * Board component for the Chinese Chess game
 */
const Board: React.FC<BoardProps> = ({ 
  width = DEFAULT_BOARD_WIDTH, 
  height = DEFAULT_BOARD_HEIGHT,
  flipped = false
}) => {
  // Get the current skin from Redux store
  const skinType = useAppSelector(state => state.game.skin);
  
  // Get the skin configuration
  const skin = getSkin(skinType || SKIN_TYPES.WOODS);
  
  // Calculate the scale factor based on the provided width
  const scale = width / DEFAULT_BOARD_WIDTH;
  
  // Calculate the actual height based on the aspect ratio
  const actualHeight = height || (DEFAULT_BOARD_HEIGHT * scale);
  
  // Get the board image
  const boardImage = skin.boardImage as ImageSourcePropType;
  
  return (
    <View style={[styles.container, { width, height: actualHeight }]}>
      <Image
        source={boardImage}
        style={[
          styles.boardImage,
          { 
            width, 
            height: actualHeight,
            transform: flipped ? [{ rotate: '180deg' }] : []
          }
        ]}
        resizeMode="contain"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    justifyContent: 'center',
    alignItems: 'center',
  },
  boardImage: {
    position: 'absolute',
  },
});

export default Board;
