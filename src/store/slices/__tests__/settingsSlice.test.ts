import settingsReducer, {
  setLanguage,
  setTheme,
  setSoundEnabled,
  setVibrationEnabled,
  setNotificationsEnabled,
  resetSettings,
} from '../settingsSlice';

describe('Settings Slice', () => {
  // Initial state test
  it('should return the initial state', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    expect(initialState.language).toBe('en');
    expect(initialState.theme).toBe('light');
    expect(initialState.soundEnabled).toBe(true);
    expect(initialState.vibrationEnabled).toBe(true);
    expect(initialState.notificationsEnabled).toBe(true);
  });
  
  // Test setLanguage action
  it('should handle setLanguage', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    // Change language to Chinese
    const chineseState = settingsReducer(initialState, setLanguage('zh'));
    expect(chineseState.language).toBe('zh');
    
    // Change language to English
    const englishState = settingsReducer(chineseState, setLanguage('en'));
    expect(englishState.language).toBe('en');
  });
  
  // Test setTheme action
  it('should handle setTheme', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    // Change theme to dark
    const darkState = settingsReducer(initialState, setTheme('dark'));
    expect(darkState.theme).toBe('dark');
    
    // Change theme to light
    const lightState = settingsReducer(darkState, setTheme('light'));
    expect(lightState.theme).toBe('light');
  });
  
  // Test setSoundEnabled action
  it('should handle setSoundEnabled', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    // Disable sound
    const soundDisabledState = settingsReducer(initialState, setSoundEnabled(false));
    expect(soundDisabledState.soundEnabled).toBe(false);
    
    // Enable sound
    const soundEnabledState = settingsReducer(soundDisabledState, setSoundEnabled(true));
    expect(soundEnabledState.soundEnabled).toBe(true);
  });
  
  // Test setVibrationEnabled action
  it('should handle setVibrationEnabled', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    // Disable vibration
    const vibrationDisabledState = settingsReducer(initialState, setVibrationEnabled(false));
    expect(vibrationDisabledState.vibrationEnabled).toBe(false);
    
    // Enable vibration
    const vibrationEnabledState = settingsReducer(vibrationDisabledState, setVibrationEnabled(true));
    expect(vibrationEnabledState.vibrationEnabled).toBe(true);
  });
  
  // Test setNotificationsEnabled action
  it('should handle setNotificationsEnabled', () => {
    const initialState = settingsReducer(undefined, { type: undefined });
    
    // Disable notifications
    const notificationsDisabledState = settingsReducer(initialState, setNotificationsEnabled(false));
    expect(notificationsDisabledState.notificationsEnabled).toBe(false);
    
    // Enable notifications
    const notificationsEnabledState = settingsReducer(notificationsDisabledState, setNotificationsEnabled(true));
    expect(notificationsEnabledState.notificationsEnabled).toBe(true);
  });
  
  // Test resetSettings action
  it('should handle resetSettings', () => {
    // Start with a modified state
    let state = settingsReducer(undefined, { type: undefined });
    state = settingsReducer(state, setLanguage('zh'));
    state = settingsReducer(state, setTheme('dark'));
    state = settingsReducer(state, setSoundEnabled(false));
    state = settingsReducer(state, setVibrationEnabled(false));
    state = settingsReducer(state, setNotificationsEnabled(false));
    
    // Reset settings
    const resetState = settingsReducer(state, resetSettings());
    
    // Check that all settings are back to default
    expect(resetState.language).toBe('en');
    expect(resetState.theme).toBe('light');
    expect(resetState.soundEnabled).toBe(true);
    expect(resetState.vibrationEnabled).toBe(true);
    expect(resetState.notificationsEnabled).toBe(true);
  });
  
  // Test multiple actions in sequence
  it('should handle multiple actions in sequence', () => {
    let state = settingsReducer(undefined, { type: undefined });
    
    // Change multiple settings
    state = settingsReducer(state, setLanguage('zh'));
    state = settingsReducer(state, setTheme('dark'));
    state = settingsReducer(state, setSoundEnabled(false));
    
    // Check that all changes were applied
    expect(state.language).toBe('zh');
    expect(state.theme).toBe('dark');
    expect(state.soundEnabled).toBe(false);
    expect(state.vibrationEnabled).toBe(true); // Unchanged
    expect(state.notificationsEnabled).toBe(true); // Unchanged
    
    // Change more settings
    state = settingsReducer(state, setVibrationEnabled(false));
    state = settingsReducer(state, setNotificationsEnabled(false));
    
    // Check that all changes were applied
    expect(state.language).toBe('zh');
    expect(state.theme).toBe('dark');
    expect(state.soundEnabled).toBe(false);
    expect(state.vibrationEnabled).toBe(false);
    expect(state.notificationsEnabled).toBe(false);
    
    // Reset settings
    state = settingsReducer(state, resetSettings());
    
    // Check that all settings are back to default
    expect(state.language).toBe('en');
    expect(state.theme).toBe('light');
    expect(state.soundEnabled).toBe(true);
    expect(state.vibrationEnabled).toBe(true);
    expect(state.notificationsEnabled).toBe(true);
  });
});
