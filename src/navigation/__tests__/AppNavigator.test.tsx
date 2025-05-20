import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import { NavigationContainer } from '@react-navigation/native';
import { AppNavigator } from '../AppNavigator';
import authReducer from '../../store/slices/authSlice';
import gameReducer from '../../store/slices/gameSlice';
import settingsReducer from '../../store/slices/settingsSlice';
import { I18nextProvider } from 'react-i18next';
import i18n from '../../i18n';

// Mock the screens
jest.mock('../../screens/HomeScreen', () => ({
  HomeScreen: () => <div data-testid="home-screen">Home Screen</div>,
}));

jest.mock('../../screens/GameScreen', () => ({
  GameScreen: () => <div data-testid="game-screen">Game Screen</div>,
}));

jest.mock('../../screens/auth/LoginScreen', () => ({
  LoginScreen: () => <div data-testid="login-screen">Login Screen</div>,
}));

jest.mock('../../screens/auth/RegisterScreen', () => ({
  RegisterScreen: () => <div data-testid="register-screen">Register Screen</div>,
}));

describe('AppNavigator Component', () => {
  // Set up test store and initial state
  const createTestStore = (initialState = {}) => {
    return configureStore({
      reducer: {
        auth: authReducer,
        game: gameReducer,
        settings: settingsReducer,
      },
      preloadedState: initialState,
    });
  };
  
  // Helper function to render the navigator with a store
  const renderWithStore = (store) => {
    return render(
      <Provider store={store}>
        <I18nextProvider i18n={i18n}>
          <NavigationContainer>
            <AppNavigator />
          </NavigationContainer>
        </I18nextProvider>
      </Provider>
    );
  };
  
  it('renders the login screen when user is not authenticated', () => {
    const store = createTestStore({
      auth: {
        user: null,
        isLoading: false,
        error: null,
      },
    });
    
    const { getByTestId } = renderWithStore(store);
    
    // Check that the login screen is rendered
    const loginScreen = getByTestId('login-screen');
    expect(loginScreen).toBeTruthy();
  });
  
  it('renders the home screen when user is authenticated', () => {
    const store = createTestStore({
      auth: {
        user: {
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
        },
        isLoading: false,
        error: null,
      },
    });
    
    const { getByTestId } = renderWithStore(store);
    
    // Check that the home screen is rendered
    const homeScreen = getByTestId('home-screen');
    expect(homeScreen).toBeTruthy();
  });
  
  it('shows loading indicator when auth state is loading', () => {
    const store = createTestStore({
      auth: {
        user: null,
        isLoading: true,
        error: null,
      },
    });
    
    const { getByTestId } = renderWithStore(store);
    
    // Check that the loading indicator is rendered
    const loadingIndicator = getByTestId('loading-indicator');
    expect(loadingIndicator).toBeTruthy();
  });
  
  it('navigates to the game screen when game mode is selected', async () => {
    const store = createTestStore({
      auth: {
        user: {
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
        },
        isLoading: false,
        error: null,
      },
      game: {
        gameMode: null,
        pieces: [],
        selectedPiece: null,
        possibleMoves: [],
        currentPlayer: 'red',
        isGameActive: false,
      },
    });
    
    const { getByTestId, getByText } = renderWithStore(store);
    
    // Check that the home screen is rendered
    const homeScreen = getByTestId('home-screen');
    expect(homeScreen).toBeTruthy();
    
    // Find and press the play button
    const playButton = getByText(/play/i);
    fireEvent.press(playButton);
    
    // Wait for navigation to complete
    await waitFor(() => {
      const gameScreen = getByTestId('game-screen');
      expect(gameScreen).toBeTruthy();
    });
  });
  
  it('navigates to the register screen from the login screen', async () => {
    const store = createTestStore({
      auth: {
        user: null,
        isLoading: false,
        error: null,
      },
    });
    
    const { getByTestId, getByText } = renderWithStore(store);
    
    // Check that the login screen is rendered
    const loginScreen = getByTestId('login-screen');
    expect(loginScreen).toBeTruthy();
    
    // Find and press the register button
    const registerButton = getByText(/register/i);
    fireEvent.press(registerButton);
    
    // Wait for navigation to complete
    await waitFor(() => {
      const registerScreen = getByTestId('register-screen');
      expect(registerScreen).toBeTruthy();
    });
  });
  
  it('navigates back to the home screen from the game screen', async () => {
    const store = createTestStore({
      auth: {
        user: {
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
        },
        isLoading: false,
        error: null,
      },
      game: {
        gameMode: 'ai',
        pieces: [],
        selectedPiece: null,
        possibleMoves: [],
        currentPlayer: 'red',
        isGameActive: true,
      },
    });
    
    const { getByTestId, getByText } = renderWithStore(store);
    
    // Check that the game screen is rendered
    const gameScreen = getByTestId('game-screen');
    expect(gameScreen).toBeTruthy();
    
    // Find and press the back button
    const backButton = getByText(/back/i);
    fireEvent.press(backButton);
    
    // Wait for navigation to complete
    await waitFor(() => {
      const homeScreen = getByTestId('home-screen');
      expect(homeScreen).toBeTruthy();
    });
  });
});
