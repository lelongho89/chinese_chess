import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useAppSelector, useAppDispatch } from '../../hooks';
import { useLocalization } from '../../hooks/useLocalization';
import { setAIDifficulty } from '../../store/slices/settingsSlice';
import { AIDifficulty } from '../../services/game/AIService';

/**
 * Props for the AISettingsComponent
 */
interface AISettingsComponentProps {
  horizontal?: boolean;
  showLabel?: boolean;
}

/**
 * AISettingsComponent for the Chinese Chess game
 * This component allows the user to select the AI difficulty level
 */
const AISettingsComponent: React.FC<AISettingsComponentProps> = ({
  horizontal = true,
  showLabel = true,
}) => {
  const dispatch = useAppDispatch();
  
  // Get the current AI difficulty from Redux store
  const selectedDifficulty = useAppSelector(state => state.settings.aiDifficulty);
  
  // Use the localization hook
  const { t } = useLocalization();
  
  // Available difficulty levels
  const difficulties = [
    { id: 'easy', name: t('settings.beginner') },
    { id: 'medium', name: t('settings.intermediate') },
    { id: 'master', name: t('settings.master') },
  ];
  
  // Handle difficulty selection
  const handleDifficultySelect = (difficultyId: string) => {
    dispatch(setAIDifficulty(difficultyId as AIDifficulty));
  };
  
  return (
    <View style={[styles.container, horizontal ? styles.horizontal : styles.vertical]}>
      {showLabel && (
        <Text style={styles.label}>{t('settings.aiLevel')}</Text>
      )}
      
      <View style={horizontal ? styles.optionsRow : styles.optionsColumn}>
        {difficulties.map(difficulty => {
          const isSelected = selectedDifficulty === difficulty.id;
          
          return (
            <TouchableOpacity
              key={difficulty.id}
              style={[
                styles.optionButton,
                isSelected && styles.selectedOption,
              ]}
              onPress={() => handleDifficultySelect(difficulty.id)}
            >
              <Text style={[
                styles.optionText,
                isSelected && styles.selectedOptionText,
              ]}>
                {difficulty.name}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 8,
  },
  horizontal: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  vertical: {
    flexDirection: 'column',
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    marginRight: 16,
    marginBottom: 8,
    color: '#444',
  },
  optionsRow: {
    flexDirection: 'row',
  },
  optionsColumn: {
    flexDirection: 'column',
    alignItems: 'stretch',
  },
  optionButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 4,
    backgroundColor: '#eee',
    marginHorizontal: 4,
    marginVertical: 4,
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
});

export default AISettingsComponent;
