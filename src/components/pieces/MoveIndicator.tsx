import React from 'react';
import { View, Image, StyleSheet, ImageSourcePropType } from 'react-native';
import { useAppSelector } from '../../hooks';
import { DEFAULT_PIECE_SIZE, SKIN_TYPES } from '../../constants';

/**
 * Props for the MoveIndicator component
 */
interface MoveIndicatorProps {
  size?: number;
  scale?: number;
}

/**
 * MoveIndicator component for the Chinese Chess game
 * This component shows a visual indicator for possible moves
 */
const MoveIndicator: React.FC<MoveIndicatorProps> = ({ 
  size = DEFAULT_PIECE_SIZE, 
  scale = 1
}) => {
  // Get the current skin from Redux store
  const skinType = useAppSelector(state => state.game.skin);
  
  // Calculate the actual size based on the scale
  const actualSize = size * scale;
  
  // Get the indicator image
  const indicatorImage = require('../../assets/skins/woods/possible_move.png') as ImageSourcePropType;
  
  return (
    <View style={[styles.container, { width: actualSize, height: actualSize }]}>
      <Image
        source={indicatorImage}
        style={[styles.indicator, { width: actualSize, height: actualSize }]}
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
  indicator: {
    position: 'absolute',
  },
});

export default MoveIndicator;
