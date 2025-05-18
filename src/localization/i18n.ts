import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-react-native-language-detector';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Import translations
import en from './locales/en.json';
import zh from './locales/zh.json';
import vi from './locales/vi.json';

// Language codes that match the ones in the settings slice
const LANGUAGE_CODES = {
  english: 'en',
  chinese: 'zh',
  vietnamese: 'vi',
};

// Map settings language to i18n language code
export const mapSettingsLanguageToCode = (language: string): string => {
  return LANGUAGE_CODES[language as keyof typeof LANGUAGE_CODES] || 'en';
};

// Map i18n language code to settings language
export const mapCodeToSettingsLanguage = (code: string): string => {
  const entries = Object.entries(LANGUAGE_CODES);
  for (const [key, value] of entries) {
    if (value === code) {
      return key;
    }
  }
  return 'english';
};

// Initialize i18next
i18n
  // Use language detector
  .use(LanguageDetector)
  // Pass the i18n instance to react-i18next
  .use(initReactI18next)
  // Initialize i18next
  .init({
    // Resources contain the translations
    resources: {
      en: {
        translation: en,
      },
      zh: {
        translation: zh,
      },
      vi: {
        translation: vi,
      },
    },
    // Fallback language
    fallbackLng: 'en',
    // Debug mode
    debug: __DEV__,
    // Cache the language
    cache: {
      enabled: true,
      expirationTime: 7 * 24 * 60 * 60 * 1000, // 7 days
      prefix: 'i18next_',
    },
    // Detect language
    detection: {
      // Order of detection
      order: ['asyncStorage', 'navigator'],
      // Cache user language
      caches: ['asyncStorage'],
      // AsyncStorage key
      lookupAsyncStorage: 'language',
      // AsyncStorage options
      asyncStorageOptions: {
        getItem: AsyncStorage.getItem,
        setItem: AsyncStorage.setItem,
        removeItem: AsyncStorage.removeItem,
      },
    },
    // Interpolation options
    interpolation: {
      escapeValue: false, // React already escapes values
    },
  });

export default i18n;
