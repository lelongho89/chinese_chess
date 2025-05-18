import { mapSettingsLanguageToCode, mapCodeToSettingsLanguage } from '../i18n';

describe('i18n utility functions', () => {
  describe('mapSettingsLanguageToCode', () => {
    it('maps english to en', () => {
      expect(mapSettingsLanguageToCode('english')).toBe('en');
    });

    it('maps chinese to zh', () => {
      expect(mapSettingsLanguageToCode('chinese')).toBe('zh');
    });

    it('maps vietnamese to vi', () => {
      expect(mapSettingsLanguageToCode('vietnamese')).toBe('vi');
    });

    it('returns en for unknown language', () => {
      expect(mapSettingsLanguageToCode('unknown' as any)).toBe('en');
    });
  });

  describe('mapCodeToSettingsLanguage', () => {
    it('maps en to english', () => {
      expect(mapCodeToSettingsLanguage('en')).toBe('english');
    });

    it('maps zh to chinese', () => {
      expect(mapCodeToSettingsLanguage('zh')).toBe('chinese');
    });

    it('maps vi to vietnamese', () => {
      expect(mapCodeToSettingsLanguage('vi')).toBe('vietnamese');
    });

    it('returns english for unknown code', () => {
      expect(mapCodeToSettingsLanguage('unknown')).toBe('english');
    });
  });
});
