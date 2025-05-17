import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import { NavigationContainer } from '@react-navigation/native';
import { configureStore } from '@reduxjs/toolkit';
import { I18nextProvider } from 'react-i18next';
import i18n from '../../i18n';
import rootReducer from '../../store/rootReducer';

/**
 * Custom renderer that includes Redux Provider, Navigation Container, and i18n
 */
const AllTheProviders = ({ children }: { children: React.ReactNode }) => {
  // Create a test store with the root reducer
  const store = configureStore({
    reducer: rootReducer,
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware({
        serializableCheck: false,
        immutableCheck: false,
      }),
  });

  return (
    <Provider store={store}>
      <I18nextProvider i18n={i18n}>
        <NavigationContainer>{children}</NavigationContainer>
      </I18nextProvider>
    </Provider>
  );
};

/**
 * Custom render function that wraps the component with all providers
 */
const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>,
) => render(ui, { wrapper: AllTheProviders, ...options });

/**
 * Create a test store with initial state
 */
const createTestStore = (initialState = {}) => {
  return configureStore({
    reducer: rootReducer,
    preloadedState: initialState,
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware({
        serializableCheck: false,
        immutableCheck: false,
      }),
  });
};

/**
 * Create a custom render function with a specific store
 */
const renderWithStore = (
  ui: ReactElement,
  { store, ...renderOptions }: { store: any } & Omit<RenderOptions, 'wrapper'>,
) => {
  const Wrapper = ({ children }: { children: React.ReactNode }) => (
    <Provider store={store}>
      <I18nextProvider i18n={i18n}>
        <NavigationContainer>{children}</NavigationContainer>
      </I18nextProvider>
    </Provider>
  );

  return render(ui, { wrapper: Wrapper, ...renderOptions });
};

// Re-export everything from testing-library
export * from '@testing-library/react-native';

// Override render method
export { customRender as render, createTestStore, renderWithStore };
