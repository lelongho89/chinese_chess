import { useTranslation } from 'react-i18next';
import { useCallback } from 'react';
import { useAppDispatch } from './useRedux';
import { setLanguage } from '../store/slices/settingsSlice';
import { mapCodeToSettingsLanguage, mapSettingsLanguageToCode } from '../localization/i18n';
import i18n from '../localization/i18n';

/**
 * Custom hook for localization
 * Provides translation function and language switching functionality
 */
export const useLocalization = () => {
  const { t, i18n } = useTranslation();
  const dispatch = useAppDispatch();

  /**
   * Change the language
   * @param language Language code or settings language name
   */
  const changeLanguage = useCallback(
    (language: string) => {
      // Check if the language is a settings language name or a language code
      const isLanguageCode = ['en', 'zh', 'vi'].includes(language);
      
      if (isLanguageCode) {
        // If it's a language code, change the language and update the settings
        i18n.changeLanguage(language);
        dispatch(setLanguage(mapCodeToSettingsLanguage(language)));
      } else {
        // If it's a settings language name, change the language
        const languageCode = mapSettingsLanguageToCode(language);
        i18n.changeLanguage(languageCode);
        dispatch(setLanguage(language as any));
      }
    },
    [dispatch]
  );

  /**
   * Get the current language
   */
  const getCurrentLanguage = useCallback(() => {
    return i18n.language;
  }, []);

  /**
   * Get the current language name
   */
  const getCurrentLanguageName = useCallback(() => {
    return mapCodeToSettingsLanguage(i18n.language);
  }, []);

  return {
    t,
    i18n,
    changeLanguage,
    getCurrentLanguage,
    getCurrentLanguageName,
  };
};

export default useLocalization;
