/**
 * Game synchronization service for online play
 */
import { store } from '../../store';
import { 
  setGameMode, 
  setPieces, 
  setCurrentPlayer, 
  setSelectedPiece, 
  setPossibleMoves,
  setGameActive,
  addToHistory,
  setFenString,
  setError,
  setOnlineGameId,
  setOpponent
} from '../../store/slices/gameSlice';
import { User } from '../../store/slices/authSlice';
import WebSocketService, { WebSocketEvent } from './WebSocketService';
import { gameService } from '../game';
import { Move } from '../game/Board';
import firestore from '@react-native-firebase/firestore';

/**
 * Online game type
 */
export interface OnlineGame {
  id: string;
  createdAt: number;
  createdBy: string;
  status: 'waiting' | 'active' | 'completed' | 'abandoned';
  players: {
    red: {
      id: string;
      name: string;
      rating?: number;
    } | null;
    black: {
      id: string;
      name: string;
      rating?: number;
    } | null;
  };
  currentFen: string;
  moves: Move[];
  winner?: 'red' | 'black' | 'draw';
  timeControl?: {
    initial: number;
    increment: number;
  };
  chat?: {
    id: string;
    senderId: string;
    senderName: string;
    message: string;
    timestamp: number;
  }[];
}

/**
 * Game synchronization service class
 */
class GameSyncService {
  private isInitialized: boolean = false;
  private currentGameId: string | null = null;
  private currentUserId: string | null = null;
  
  /**
   * Initialize the game synchronization service
   * @param userId User ID
   * @param token Authentication token
   */
  initialize(userId: string, token: string): void {
    if (this.isInitialized) {
      return;
    }
    
    this.currentUserId = userId;
    
    // Connect to WebSocket server
    WebSocketService.connect(userId, token);
    
    // Set up event listeners
    this.setupEventListeners();
    
    this.isInitialized = true;
  }
  
  /**
   * Clean up the game synchronization service
   */
  cleanup(): void {
    if (!this.isInitialized) {
      return;
    }
    
    // Disconnect from WebSocket server
    WebSocketService.disconnect();
    
    // Reset state
    this.isInitialized = false;
    this.currentGameId = null;
    this.currentUserId = null;
  }
  
  /**
   * Create a new online game
   * @param timeControl Time control in seconds
   * @param increment Increment in seconds
   */
  createGame(timeControl?: number, increment?: number): void {
    WebSocketService.createGame({
      timeControl,
      increment,
    });
  }
  
  /**
   * Join an existing online game
   * @param gameId Game ID
   */
  joinGame(gameId: string): void {
    this.currentGameId = gameId;
    WebSocketService.joinGame(gameId);
  }
  
  /**
   * Make a move in the current online game
   * @param move Move to make
   */
  makeMove(move: Move): void {
    WebSocketService.makeMove(move);
  }
  
  /**
   * Leave the current online game
   */
  leaveGame(): void {
    if (this.currentGameId) {
      WebSocketService.leaveGame();
      this.currentGameId = null;
      
      // Reset game state
      store.dispatch(setOnlineGameId(null));
      store.dispatch(setOpponent(null));
    }
  }
  
  /**
   * Send a chat message in the current game
   * @param message Chat message
   */
  sendChatMessage(message: string): void {
    WebSocketService.sendChatMessage(message);
  }
  
  /**
   * Send a game invitation to another user
   * @param receiverId Receiver user ID
   * @param timeControl Time control in seconds
   * @param increment Increment in seconds
   */
  sendInvitation(receiverId: string, timeControl?: number, increment?: number): void {
    WebSocketService.sendInvitation(receiverId, {
      timeControl,
      increment,
    });
  }
  
  /**
   * Accept a game invitation
   * @param invitationId Invitation ID
   */
  acceptInvitation(invitationId: string): void {
    WebSocketService.acceptInvitation(invitationId);
  }
  
  /**
   * Decline a game invitation
   * @param invitationId Invitation ID
   */
  declineInvitation(invitationId: string): void {
    WebSocketService.declineInvitation(invitationId);
  }
  
  /**
   * Get available online games
   * @returns Promise with array of online games
   */
  async getAvailableGames(): Promise<OnlineGame[]> {
    try {
      // Get games with status 'waiting'
      const snapshot = await firestore()
        .collection('games')
        .where('status', '==', 'waiting')
        .orderBy('createdAt', 'desc')
        .limit(20)
        .get();
      
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      })) as OnlineGame[];
    } catch (error) {
      console.error('Error getting available games:', error);
      store.dispatch(setError('Failed to get available games'));
      return [];
    }
  }
  
  /**
   * Get user's active games
   * @param userId User ID
   * @returns Promise with array of active games
   */
  async getUserActiveGames(userId: string): Promise<OnlineGame[]> {
    try {
      // Get games where user is a player and status is 'active'
      const snapshot = await firestore()
        .collection('games')
        .where('status', '==', 'active')
        .where(`players.red.id`, '==', userId)
        .get();
      
      const snapshot2 = await firestore()
        .collection('games')
        .where('status', '==', 'active')
        .where(`players.black.id`, '==', userId)
        .get();
      
      // Combine results
      const games = [
        ...snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        ...snapshot2.docs.map(doc => ({ id: doc.id, ...doc.data() })),
      ] as OnlineGame[];
      
      return games;
    } catch (error) {
      console.error('Error getting user active games:', error);
      store.dispatch(setError('Failed to get active games'));
      return [];
    }
  }
  
  /**
   * Get user's game history
   * @param userId User ID
   * @param limit Number of games to return
   * @returns Promise with array of completed games
   */
  async getUserGameHistory(userId: string, limit: number = 20): Promise<OnlineGame[]> {
    try {
      // Get games where user is a player and status is 'completed'
      const snapshot = await firestore()
        .collection('games')
        .where('status', '==', 'completed')
        .where(`players.red.id`, '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(limit)
        .get();
      
      const snapshot2 = await firestore()
        .collection('games')
        .where('status', '==', 'completed')
        .where(`players.black.id`, '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(limit)
        .get();
      
      // Combine results and sort by createdAt
      const games = [
        ...snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        ...snapshot2.docs.map(doc => ({ id: doc.id, ...doc.data() })),
      ] as OnlineGame[];
      
      return games.sort((a, b) => b.createdAt - a.createdAt).slice(0, limit);
    } catch (error) {
      console.error('Error getting user game history:', error);
      store.dispatch(setError('Failed to get game history'));
      return [];
    }
  }
  
  /**
   * Set up WebSocket event listeners
   */
  private setupEventListeners(): void {
    // Game created event
    WebSocketService.on(WebSocketEvent.GAME_CREATED, (payload) => {
      console.log('Game created:', payload);
      
      // Set game ID
      this.currentGameId = payload.gameId;
      store.dispatch(setOnlineGameId(payload.gameId));
      
      // Set game mode
      store.dispatch(setGameMode('online'));
      
      // Initialize game
      gameService.initGame('online', payload.fen);
    });
    
    // Game joined event
    WebSocketService.on(WebSocketEvent.GAME_JOINED, (payload) => {
      console.log('Game joined:', payload);
      
      // Set opponent
      if (payload.player.id !== this.currentUserId) {
        store.dispatch(setOpponent({
          id: payload.player.id,
          displayName: payload.player.name,
        } as User));
      }
    });
    
    // Game started event
    WebSocketService.on(WebSocketEvent.GAME_STARTED, (payload) => {
      console.log('Game started:', payload);
      
      // Set game active
      store.dispatch(setGameActive(true));
      
      // Initialize game with FEN
      gameService.loadFromFen(payload.fen);
      store.dispatch(setFenString(payload.fen));
      
      // Set current player
      store.dispatch(setCurrentPlayer(payload.currentPlayer));
    });
    
    // Move made event
    WebSocketService.on(WebSocketEvent.MOVE_MADE, (payload) => {
      console.log('Move made:', payload);
      
      // Update game state
      gameService.makeMove(
        payload.move.from.row,
        payload.move.from.col,
        payload.move.to.row,
        payload.move.to.col
      );
      
      // Add move to history
      store.dispatch(addToHistory(payload.move));
      
      // Update FEN
      store.dispatch(setFenString(payload.fen));
      
      // Update current player
      store.dispatch(setCurrentPlayer(payload.currentPlayer));
      
      // Clear selection
      store.dispatch(setSelectedPiece(null));
      store.dispatch(setPossibleMoves([]));
    });
    
    // Game ended event
    WebSocketService.on(WebSocketEvent.GAME_ENDED, (payload) => {
      console.log('Game ended:', payload);
      
      // Set game inactive
      store.dispatch(setGameActive(false));
      
      // Update game state
      gameService.loadFromFen(payload.fen);
      store.dispatch(setFenString(payload.fen));
      
      // Show result
      // This will be handled by the UI
    });
    
    // Game state event
    WebSocketService.on(WebSocketEvent.GAME_STATE, (payload) => {
      console.log('Game state:', payload);
      
      // Update game state
      gameService.loadFromFen(payload.fen);
      store.dispatch(setFenString(payload.fen));
      
      // Update current player
      store.dispatch(setCurrentPlayer(payload.currentPlayer));
      
      // Update history
      payload.moves.forEach((move: Move) => {
        store.dispatch(addToHistory(move));
      });
      
      // Update pieces
      store.dispatch(setPieces(gameService.getBoardState()));
    });
  }
}

// Export a singleton instance
export default new GameSyncService();
