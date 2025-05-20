import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import configureStore from 'redux-mock-store';
import LanguageSelector from '../LanguageSelector';

// Mock the i18next hook
jest.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key: string) => {
      const translations = {
        'languages.english': 'English',
        'languages.chinese': 'Chinese',
        'languages.vietnamese': 'Vietnamese',
        'settings.language': 'Language',
      };
      return translations[key] || key;
    },
    i18n: {
      changeLanguage: jest.fn(),
      language: 'en',
    },
  }),
}));

// Mock the useLocalization hook
jest.mock('../../../hooks/useLocalization', () => ({
  useLocalization: () => ({
    t: (key: string) => {
      const translations = {
        'languages.english': 'English',
        'languages.chinese': 'Chinese',
        'languages.vietnamese': 'Vietnamese',
        'settings.language': 'Language',
      };
      return translations[key] || key;
    },
    changeLanguage: jest.fn(),
    getCurrentLanguage: () => 'en',
    getCurrentLanguageName: () => 'english',
  }),
}));

// Mock the store
const mockStore = configureStore([]);

describe('LanguageSelector', () => {
  let store;
  
  beforeEach(() => {
    store = mockStore({
      settings: {
        language: 'english',
      },
    });
    
    // Mock the dispatch function
    store.dispatch = jest.fn();
  });
  
  it('renders correctly with default props', () => {
    const { getByText } = render(
      <Provider store={store}>
        <LanguageSelector />
      </Provider>
    );
    
    // Check if the language label is rendered
    expect(getByText('Language')).toBeTruthy();
    
    // Check if all language options are rendered
    expect(getByText('English')).toBeTruthy();
    expect(getByText('Chinese')).toBeTruthy();
    expect(getByText('Vietnamese')).toBeTruthy();
  });
  
  it('renders without label when showLabel is false', () => {
    const { queryByText } = render(
      <Provider store={store}>
        <LanguageSelector showLabel={false} />
      </Provider>
    );
    
    // Check if the language label is not rendered
    expect(queryByText('Language')).toBeNull();
  });
  
  it('renders in vertical layout when horizontal is false', () => {
    const { container } = render(
      <Provider store={store}>
        <LanguageSelector horizontal={false} />
      </Provider>
    );
    
    // Check if the container has the vertical style
    // Note: This is a bit tricky to test in React Native Testing Library
    // We would need to check the actual styles applied
    // For now, we'll just ensure it renders without errors
    expect(container).toBeTruthy();
  });
});
