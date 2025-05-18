import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Image, ImageSourcePropType } from 'react-native';
import { useAppSelector, useAppDispatch } from '../../hooks';
import { setSkin } from '../../store/slices/gameSlice';
import { SKIN_TYPES, getSkin } from '../../constants';

/**
 * Props for the SkinSelector component
 */
interface SkinSelectorProps {
  showPreview?: boolean;
  previewSize?: number;
  horizontal?: boolean;
}

/**
 * SkinSelector component for the Chinese Chess game
 * This component allows the user to select a skin for the game
 */
const SkinSelector: React.FC<SkinSelectorProps> = ({
  showPreview = true,
  previewSize = 100,
  horizontal = true,
}) => {
  const dispatch = useAppDispatch();
  
  // Get the current skin from Redux store
  const selectedSkin = useAppSelector(state => state.game.skin);
  
  // Available skins
  const skins = [
    { id: SKIN_TYPES.WOODS, name: 'Woods' },
    { id: SKIN_TYPES.STONES, name: 'Stones' },
  ];
  
  // Handle skin selection
  const handleSkinSelect = (skinId: string) => {
    dispatch(setSkin(skinId));
  };
  
  return (
    <View style={[styles.container, horizontal ? styles.horizontal : styles.vertical]}>
      {skins.map(skin => {
        const isSelected = selectedSkin === skin.id;
        const skinConfig = getSkin(skin.id);
        
        return (
          <View key={skin.id} style={styles.skinOption}>
            <TouchableOpacity
              style={[
                styles.optionButton,
                isSelected && styles.selectedOption,
              ]}
              onPress={() => handleSkinSelect(skin.id)}
            >
              <Text style={[
                styles.optionText,
                isSelected && styles.selectedOptionText,
              ]}>
                {skin.name}
              </Text>
            </TouchableOpacity>
            
            {showPreview && (
              <View style={[styles.previewContainer, { width: previewSize, height: previewSize }]}>
                <Image
                  source={skinConfig.boardImage as ImageSourcePropType}
                  style={[styles.previewImage, { width: previewSize, height: previewSize }]}
                  resizeMode="contain"
                />
                {isSelected && (
                  <View style={styles.selectedIndicator} />
                )}
              </View>
            )}
          </View>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  horizontal: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  vertical: {
    flexDirection: 'column',
    alignItems: 'center',
  },
  skinOption: {
    alignItems: 'center',
    marginHorizontal: 8,
    marginVertical: 8,
  },
  optionButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 4,
    backgroundColor: '#eee',
    marginBottom: 8,
    minWidth: 100,
    alignItems: 'center',
  },
  selectedOption: {
    backgroundColor: '#f4511e',
  },
  optionText: {
    color: '#333',
    fontSize: 14,
    fontWeight: 'bold',
  },
  selectedOptionText: {
    color: 'white',
  },
  previewContainer: {
    position: 'relative',
    borderRadius: 8,
    overflow: 'hidden',
    borderWidth: 2,
    borderColor: '#ddd',
  },
  previewImage: {
    position: 'absolute',
  },
  selectedIndicator: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderWidth: 3,
    borderColor: '#f4511e',
    borderRadius: 6,
  },
});

export default SkinSelector;
