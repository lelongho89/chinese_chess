import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, Switch, TouchableOpacity, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { SettingsScreenNavigationProp } from '../navigation/types';
import { useAppSelector, useAppDispatch } from '../hooks';
import { useLocalization } from '../hooks/useLocalization';
import {
  setSoundEnabled,
  setMusicEnabled,
  setNotificationsEnabled,
  setSkin,
  setLanguage,
} from '../store';
import { AISettingsComponent } from '../components/ui';

/**
 * Settings screen component for the Chinese Chess application
 */
const SettingsScreen: React.FC = () => {
  const navigation = useNavigation<SettingsScreenNavigationProp>();
  const dispatch = useAppDispatch();
  const { t } = useLocalization();

  // Get settings from Redux store
  const soundEnabled = useAppSelector(state => state.settings.soundEnabled);
  const musicEnabled = useAppSelector(state => state.settings.musicEnabled);
  const notificationsEnabled = useAppSelector(state => state.settings.notificationsEnabled);
  const selectedLanguage = useAppSelector(state => state.settings.language);
  const selectedSkin = useAppSelector(state => state.game.skin);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>{t('settings.audioSettings')}</Text>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>{t('settings.soundEffects')}</Text>
          <Switch
            value={soundEnabled}
            onValueChange={(value) => dispatch(setSoundEnabled(value))}
            trackColor={{ false: '#767577', true: '#f4511e' }}
            thumbColor={soundEnabled ? '#f4511e' : '#f4f3f4'}
          />
        </View>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>{t('settings.backgroundMusic')}</Text>
          <Switch
            value={musicEnabled}
            onValueChange={(value) => dispatch(setMusicEnabled(value))}
            trackColor={{ false: '#767577', true: '#f4511e' }}
            thumbColor={musicEnabled ? '#f4511e' : '#f4f3f4'}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>{t('settings.appearance')}</Text>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>{t('settings.skin')}</Text>
          <View style={styles.optionsContainer}>
            <TouchableOpacity
              style={[
                styles.optionButton,
                selectedSkin === 'woods' && styles.selectedOption,
              ]}
              onPress={() => dispatch(setSkin('woods'))}>
              <Text style={styles.optionText}>{t('settings.skinWoods')}</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.optionButton,
                selectedSkin === 'stones' && styles.selectedOption,
              ]}
              onPress={() => dispatch(setSkin('stones'))}>
              <Text style={styles.optionText}>{t('settings.skinStones')}</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>{t('settings.language')}</Text>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>{t('settings.language')}</Text>
          <View style={styles.optionsContainer}>
            <TouchableOpacity
              style={[
                styles.optionButton,
                selectedLanguage === 'english' && styles.selectedOption,
              ]}
              onPress={() => dispatch(setLanguage('english'))}>
              <Text style={styles.optionText}>{t('languages.english')}</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.optionButton,
                selectedLanguage === 'chinese' && styles.selectedOption,
              ]}
              onPress={() => dispatch(setLanguage('chinese'))}>
              <Text style={styles.optionText}>{t('languages.chinese')}</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.optionButton,
                selectedLanguage === 'vietnamese' && styles.selectedOption,
              ]}
              onPress={() => dispatch(setLanguage('vietnamese'))}>
              <Text style={styles.optionText}>{t('languages.vietnamese')}</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>{t('settings.aiLevel')}</Text>

        <View style={styles.settingRow}>
          <AISettingsComponent horizontal={false} showLabel={false} />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>{t('settings.notifications')}</Text>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>{t('settings.enableNotifications')}</Text>
          <Switch
            value={notificationsEnabled}
            onValueChange={(value) => dispatch(setNotificationsEnabled(value))}
            trackColor={{ false: '#767577', true: '#f4511e' }}
            thumbColor={notificationsEnabled ? '#f4511e' : '#f4f3f4'}
          />
        </View>
      </View>

      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={styles.saveButton}
          onPress={() => navigation.goBack()}>
          <Text style={styles.saveButtonText}>{t('settings.saveSettings')}</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  section: {
    marginBottom: 24,
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  settingLabel: {
    fontSize: 16,
    color: '#444',
  },
  optionsContainer: {
    flexDirection: 'row',
  },
  optionButton: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 4,
    backgroundColor: '#eee',
    marginLeft: 8,
  },
  selectedOption: {
    backgroundColor: '#f4511e',
  },
  optionText: {
    color: '#333',
    fontSize: 14,
  },
  buttonContainer: {
    marginTop: 16,
    alignItems: 'center',
  },
  saveButton: {
    backgroundColor: '#4a6ea9',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    width: '80%',
    alignItems: 'center',
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default SettingsScreen;
