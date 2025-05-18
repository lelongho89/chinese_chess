import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useAppSelector } from '../../hooks';
import { useLocalization } from '../../hooks/useLocalization';

/**
 * Props for the LanguageSelector component
 */
interface LanguageSelectorProps {
  horizontal?: boolean;
  showLabel?: boolean;
}

/**
 * LanguageSelector component for the Chinese Chess game
 * This component allows the user to select a language for the game
 */
const LanguageSelector: React.FC<LanguageSelectorProps> = ({
  horizontal = true,
  showLabel = true,
}) => {
  // Get the current language from Redux store
  const selectedLanguage = useAppSelector(state => state.settings.language);
  
  // Use the localization hook
  const { t, changeLanguage } = useLocalization();
  
  // Available languages
  const languages = [
    { id: 'english', name: t('languages.english') },
    { id: 'chinese', name: t('languages.chinese') },
    { id: 'vietnamese', name: t('languages.vietnamese') },
  ];
  
  // Handle language selection
  const handleLanguageSelect = (languageId: string) => {
    changeLanguage(languageId);
  };
  
  return (
    <View style={[styles.container, horizontal ? styles.horizontal : styles.vertical]}>
      {showLabel && (
        <Text style={styles.label}>{t('settings.language')}</Text>
      )}
      
      <View style={horizontal ? styles.optionsRow : styles.optionsColumn}>
        {languages.map(language => {
          const isSelected = selectedLanguage === language.id;
          
          return (
            <TouchableOpacity
              key={language.id}
              style={[
                styles.optionButton,
                isSelected && styles.selectedOption,
              ]}
              onPress={() => handleLanguageSelect(language.id)}
            >
              <Text style={[
                styles.optionText,
                isSelected && styles.selectedOptionText,
              ]}>
                {language.name}
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

export default LanguageSelector;
