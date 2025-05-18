import React from 'react';
import { render, fireEvent, waitFor } from '../../utils/testing/test-utils';
import { GameScreen } from '../GameScreen';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import gameReducer from '../../store/slices/gameSlice';
import { gameService } from '../../services/game';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

// Mock the game service
jest.mock('../../services/game', () => ({
  gameService: {
    initGame: jest.fn(),
    resetGame: jest.fn(),
    getBoardState: jest.fn(() => []),
    getCurrentPlayer: jest.fn(() => 'red'),
    isGameActive: jest.fn(() => true),
    getGameResult: jest.fn(() => ({ winner: null, reason: null })),
  },
}));

// Mock the navigation
const Stack = createStackNavigator();
const MockNavigator = ({ component, params = {} }) => (
  <NavigationContainer>
    <Stack.Navigator>
      <Stack.Screen
        name="MockScreen"
        component={component}
        initialParams={params}
      />
    </Stack.Navigator>
  </NavigationContainer>
);

describe('GameScreen Component', () => {
  // Set up test store and initial state
  const createTestStore = (initialState = {}) => {
    return configureStore({
      reducer: {
        game: gameReducer,
      },
      preloadedState: {
        game: {
          gameMode: 'ai',
          pieces: [],
          selectedPiece: null,
          possibleMoves: [],
          currentPlayer: 'red',
          isGameActive: true,
          gameResult: { winner: null, reason: null },
          ...initialState,
        },
      },
    });
  };
  
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('renders correctly with default props', () => {
    const store = createTestStore();
    
    const { getByTestId } = render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Check that the game screen is rendered
    const gameScreen = getByTestId('game-screen');
    expect(gameScreen).toBeTruthy();
    
    // Check that the chess board is rendered
    const chessBoard = getByTestId('chess-board');
    expect(chessBoard).toBeTruthy();
  });
  
  it('initializes the game with the correct mode', () => {
    const store = createTestStore();
    
    render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Check that the game was initialized with the correct mode
    expect(gameService.initGame).toHaveBeenCalledWith('ai');
  });
  
  it('shows the current player', () => {
    const store = createTestStore({ currentPlayer: 'red' });
    
    const { getByText } = render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Check that the current player is displayed
    const playerText = getByText(/red/i);
    expect(playerText).toBeTruthy();
  });
  
  it('shows game result when game is over', async () => {
    // Mock game result
    (gameService.isGameActive as jest.Mock).mockReturnValue(false);
    (gameService.getGameResult as jest.Mock).mockReturnValue({
      winner: 'red',
      reason: 'checkmate',
    });
    
    const store = createTestStore({
      isGameActive: false,
      gameResult: { winner: 'red', reason: 'checkmate' },
    });
    
    const { getByText } = render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Check that the game result is displayed
    await waitFor(() => {
      const resultText = getByText(/red wins/i);
      expect(resultText).toBeTruthy();
    });
  });
  
  it('handles new game button press', () => {
    const store = createTestStore();
    
    const { getByText } = render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Find and press the new game button
    const newGameButton = getByText(/new game/i);
    fireEvent.press(newGameButton);
    
    // Check that the game was reset and initialized
    expect(gameService.resetGame).toHaveBeenCalled();
    expect(gameService.initGame).toHaveBeenCalledWith('ai');
  });
  
  it('handles undo button press', () => {
    // Mock the undo method
    const undoMock = jest.fn();
    gameService.undo = undoMock;
    
    const store = createTestStore();
    
    const { getByText } = render(
      <Provider store={store}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Find and press the undo button
    const undoButton = getByText(/undo/i);
    fireEvent.press(undoButton);
    
    // Check that the undo method was called
    expect(undoMock).toHaveBeenCalled();
  });
  
  it('handles different game modes', () => {
    // Test AI mode
    const aiStore = createTestStore({ gameMode: 'ai' });
    
    const { unmount, getByTestId } = render(
      <Provider store={aiStore}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'ai' }}
        />
      </Provider>
    );
    
    // Check that the AI mode is displayed
    const aiModeText = getByTestId('game-mode-text');
    expect(aiModeText.props.children).toMatch(/ai/i);
    
    unmount();
    
    // Test free play mode
    const freeStore = createTestStore({ gameMode: 'free' });
    
    const { getByTestId: getFreeTestId } = render(
      <Provider store={freeStore}>
        <MockNavigator
          component={GameScreen}
          params={{ gameMode: 'free' }}
        />
      </Provider>
    );
    
    // Check that the free play mode is displayed
    const freeModeText = getFreeTestId('game-mode-text');
    expect(freeModeText.props.children).toMatch(/free/i);
  });
});
