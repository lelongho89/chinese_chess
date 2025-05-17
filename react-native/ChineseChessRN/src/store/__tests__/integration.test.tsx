import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from '../rootReducer';
import { setUser, logout } from '../slices/authSlice';
import { setGameMode, setPieces, setSelectedPiece } from '../slices/gameSlice';
import { setLanguage, setTheme } from '../slices/settingsSlice';
import { Text, TouchableOpacity, View } from 'react-native';

// Create a test component that uses Redux state
const TestComponent = ({ 
  onLogin, 
  onLogout, 
  onStartGame, 
  onSelectPiece,
  onChangeLanguage,
  onChangeTheme
}) => {
  return (
    <View>
      <TouchableOpacity testID="login-button" onPress={onLogin}>
        <Text>Login</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="logout-button" onPress={onLogout}>
        <Text>Logout</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="start-game-button" onPress={onStartGame}>
        <Text>Start Game</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="select-piece-button" onPress={onSelectPiece}>
        <Text>Select Piece</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="change-language-button" onPress={onChangeLanguage}>
        <Text>Change Language</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="change-theme-button" onPress={onChangeTheme}>
        <Text>Change Theme</Text>
      </TouchableOpacity>
    </View>
  );
};

describe('Redux Integration', () => {
  // Set up test store
  let store;
  
  beforeEach(() => {
    store = configureStore({
      reducer: rootReducer,
    });
  });
  
  it('updates auth state when user logs in and out', async () => {
    // Create a test user
    const testUser = {
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    };
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => store.dispatch(setUser(testUser))}
          onLogout={() => store.dispatch(logout())}
          onStartGame={() => {}}
          onSelectPiece={() => {}}
          onChangeLanguage={() => {}}
          onChangeTheme={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().auth.user).toBeNull();
    
    // Login
    fireEvent.press(getByTestId('login-button'));
    
    // Check that the user is set
    expect(store.getState().auth.user).toEqual(testUser);
    
    // Logout
    fireEvent.press(getByTestId('logout-button'));
    
    // Check that the user is null
    expect(store.getState().auth.user).toBeNull();
  });
  
  it('updates game state when game is started and piece is selected', async () => {
    // Create test pieces
    const testPieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => {}}
          onLogout={() => {}}
          onStartGame={() => {
            store.dispatch(setGameMode('ai'));
            store.dispatch(setPieces(testPieces));
          }}
          onSelectPiece={() => store.dispatch(setSelectedPiece(testPieces[0]))}
          onChangeLanguage={() => {}}
          onChangeTheme={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().game.gameMode).toBeNull();
    expect(store.getState().game.pieces).toEqual([]);
    expect(store.getState().game.selectedPiece).toBeNull();
    
    // Start game
    fireEvent.press(getByTestId('start-game-button'));
    
    // Check that the game mode and pieces are set
    expect(store.getState().game.gameMode).toBe('ai');
    expect(store.getState().game.pieces).toEqual(testPieces);
    
    // Select piece
    fireEvent.press(getByTestId('select-piece-button'));
    
    // Check that the selected piece is set
    expect(store.getState().game.selectedPiece).toEqual(testPieces[0]);
  });
  
  it('updates settings state when language and theme are changed', async () => {
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => {}}
          onLogout={() => {}}
          onStartGame={() => {}}
          onSelectPiece={() => {}}
          onChangeLanguage={() => store.dispatch(setLanguage('zh'))}
          onChangeTheme={() => store.dispatch(setTheme('dark'))}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().settings.language).toBe('en');
    expect(store.getState().settings.theme).toBe('light');
    
    // Change language
    fireEvent.press(getByTestId('change-language-button'));
    
    // Check that the language is changed
    expect(store.getState().settings.language).toBe('zh');
    
    // Change theme
    fireEvent.press(getByTestId('change-theme-button'));
    
    // Check that the theme is changed
    expect(store.getState().settings.theme).toBe('dark');
  });
  
  it('handles multiple state changes in sequence', async () => {
    // Create test data
    const testUser = {
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    };
    
    const testPieces = [
      {
        id: 'r1',
        type: 'rook',
        position: { row: 0, col: 0 },
        color: 'red',
      },
    ];
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => store.dispatch(setUser(testUser))}
          onLogout={() => store.dispatch(logout())}
          onStartGame={() => {
            store.dispatch(setGameMode('ai'));
            store.dispatch(setPieces(testPieces));
          }}
          onSelectPiece={() => store.dispatch(setSelectedPiece(testPieces[0]))}
          onChangeLanguage={() => store.dispatch(setLanguage('zh'))}
          onChangeTheme={() => store.dispatch(setTheme('dark'))}
        />
      </Provider>
    );
    
    // Login
    fireEvent.press(getByTestId('login-button'));
    
    // Start game
    fireEvent.press(getByTestId('start-game-button'));
    
    // Change language
    fireEvent.press(getByTestId('change-language-button'));
    
    // Change theme
    fireEvent.press(getByTestId('change-theme-button'));
    
    // Select piece
    fireEvent.press(getByTestId('select-piece-button'));
    
    // Check final state
    expect(store.getState().auth.user).toEqual(testUser);
    expect(store.getState().game.gameMode).toBe('ai');
    expect(store.getState().game.pieces).toEqual(testPieces);
    expect(store.getState().game.selectedPiece).toEqual(testPieces[0]);
    expect(store.getState().settings.language).toBe('zh');
    expect(store.getState().settings.theme).toBe('dark');
    
    // Logout
    fireEvent.press(getByTestId('logout-button'));
    
    // Check that the user is null but other state remains
    expect(store.getState().auth.user).toBeNull();
    expect(store.getState().game.gameMode).toBe('ai');
    expect(store.getState().settings.language).toBe('zh');
  });
});
