/**
 * WebSocket service for real-time game synchronization
 */
import { EventEmitter } from 'events';
import { store } from '../../store';
import { setError } from '../../store/slices/gameSlice';
import { Move } from '../game/Board';

// WebSocket event types
export enum WebSocketEvent {
  CONNECT = 'connect',
  DISCONNECT = 'disconnect',
  ERROR = 'error',
  GAME_CREATED = 'game_created',
  GAME_JOINED = 'game_joined',
  GAME_STARTED = 'game_started',
  GAME_ENDED = 'game_ended',
  MOVE_MADE = 'move_made',
  PLAYER_JOINED = 'player_joined',
  PLAYER_LEFT = 'player_left',
  CHAT_MESSAGE = 'chat_message',
  GAME_STATE = 'game_state',
  INVITATION_SENT = 'invitation_sent',
  INVITATION_ACCEPTED = 'invitation_accepted',
  INVITATION_DECLINED = 'invitation_declined',
}

// WebSocket message types
export enum MessageType {
  CREATE_GAME = 'create_game',
  JOIN_GAME = 'join_game',
  MAKE_MOVE = 'make_move',
  LEAVE_GAME = 'leave_game',
  SEND_CHAT = 'send_chat',
  REQUEST_GAME_STATE = 'request_game_state',
  SEND_INVITATION = 'send_invitation',
  ACCEPT_INVITATION = 'accept_invitation',
  DECLINE_INVITATION = 'decline_invitation',
}

// Game invitation type
export interface GameInvitation {
  id: string;
  senderId: string;
  senderName: string;
  receiverId: string;
  timestamp: number;
  gameOptions?: {
    timeControl?: number;
    increment?: number;
  };
}

// WebSocket message type
export interface WebSocketMessage {
  type: MessageType;
  payload: any;
}

/**
 * WebSocket service class
 */
class WebSocketService {
  private socket: WebSocket | null = null;
  private eventEmitter: EventEmitter;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectTimeout: number = 1000; // Start with 1 second
  private reconnectTimer: NodeJS.Timeout | null = null;
  private pingInterval: NodeJS.Timeout | null = null;
  private gameId: string | null = null;
  private userId: string | null = null;
  
  /**
   * Constructor
   */
  constructor() {
    this.eventEmitter = new EventEmitter();
  }
  
  /**
   * Connect to the WebSocket server
   * @param userId User ID
   * @param token Authentication token
   */
  connect(userId: string, token: string): void {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      console.log('WebSocket already connected');
      return;
    }
    
    this.userId = userId;
    
    // Connect to the WebSocket server
    try {
      // Use secure WebSocket if in production
      const protocol = process.env.NODE_ENV === 'production' ? 'wss' : 'ws';
      const host = process.env.REACT_APP_WS_HOST || 'localhost:8080';
      
      this.socket = new WebSocket(`${protocol}://${host}/ws?token=${token}`);
      
      // Set up event listeners
      this.socket.onopen = this.handleOpen.bind(this);
      this.socket.onmessage = this.handleMessage.bind(this);
      this.socket.onclose = this.handleClose.bind(this);
      this.socket.onerror = this.handleError.bind(this);
      
      // Start ping interval to keep connection alive
      this.startPingInterval();
    } catch (error) {
      console.error('WebSocket connection error:', error);
      store.dispatch(setError('Failed to connect to game server'));
    }
  }
  
  /**
   * Disconnect from the WebSocket server
   */
  disconnect(): void {
    if (this.socket) {
      // Clear timers
      if (this.pingInterval) {
        clearInterval(this.pingInterval);
        this.pingInterval = null;
      }
      
      if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer);
        this.reconnectTimer = null;
      }
      
      // Close the connection
      this.socket.close();
      this.socket = null;
      this.gameId = null;
      
      // Reset reconnect attempts
      this.reconnectAttempts = 0;
      
      // Emit disconnect event
      this.eventEmitter.emit(WebSocketEvent.DISCONNECT);
    }
  }
  
  /**
   * Create a new game
   * @param options Game options
   */
  createGame(options: any): void {
    this.sendMessage({
      type: MessageType.CREATE_GAME,
      payload: options,
    });
  }
  
  /**
   * Join an existing game
   * @param gameId Game ID
   */
  joinGame(gameId: string): void {
    this.gameId = gameId;
    
    this.sendMessage({
      type: MessageType.JOIN_GAME,
      payload: { gameId },
    });
  }
  
  /**
   * Make a move in the current game
   * @param move Move to make
   */
  makeMove(move: Move): void {
    if (!this.gameId) {
      console.error('No active game');
      return;
    }
    
    this.sendMessage({
      type: MessageType.MAKE_MOVE,
      payload: {
        gameId: this.gameId,
        move,
      },
    });
  }
  
  /**
   * Leave the current game
   */
  leaveGame(): void {
    if (!this.gameId) {
      console.error('No active game');
      return;
    }
    
    this.sendMessage({
      type: MessageType.LEAVE_GAME,
      payload: {
        gameId: this.gameId,
      },
    });
    
    this.gameId = null;
  }
  
  /**
   * Send a chat message
   * @param message Chat message
   */
  sendChatMessage(message: string): void {
    if (!this.gameId) {
      console.error('No active game');
      return;
    }
    
    this.sendMessage({
      type: MessageType.SEND_CHAT,
      payload: {
        gameId: this.gameId,
        message,
      },
    });
  }
  
  /**
   * Request the current game state
   */
  requestGameState(): void {
    if (!this.gameId) {
      console.error('No active game');
      return;
    }
    
    this.sendMessage({
      type: MessageType.REQUEST_GAME_STATE,
      payload: {
        gameId: this.gameId,
      },
    });
  }
  
  /**
   * Send a game invitation
   * @param receiverId Receiver user ID
   * @param gameOptions Game options
   */
  sendInvitation(receiverId: string, gameOptions?: any): void {
    this.sendMessage({
      type: MessageType.SEND_INVITATION,
      payload: {
        receiverId,
        gameOptions,
      },
    });
  }
  
  /**
   * Accept a game invitation
   * @param invitationId Invitation ID
   */
  acceptInvitation(invitationId: string): void {
    this.sendMessage({
      type: MessageType.ACCEPT_INVITATION,
      payload: {
        invitationId,
      },
    });
  }
  
  /**
   * Decline a game invitation
   * @param invitationId Invitation ID
   */
  declineInvitation(invitationId: string): void {
    this.sendMessage({
      type: MessageType.DECLINE_INVITATION,
      payload: {
        invitationId,
      },
    });
  }
  
  /**
   * Add an event listener
   * @param event Event type
   * @param listener Event listener
   */
  on(event: WebSocketEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.on(event, listener);
  }
  
  /**
   * Remove an event listener
   * @param event Event type
   * @param listener Event listener
   */
  off(event: WebSocketEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.off(event, listener);
  }
  
  /**
   * Send a message to the WebSocket server
   * @param message Message to send
   */
  private sendMessage(message: WebSocketMessage): void {
    if (this.socket && this.socket.readyState === WebSocket.OPEN) {
      this.socket.send(JSON.stringify(message));
    } else {
      console.error('WebSocket not connected');
      store.dispatch(setError('Not connected to game server'));
    }
  }
  
  /**
   * Handle WebSocket open event
   */
  private handleOpen(): void {
    console.log('WebSocket connected');
    
    // Reset reconnect attempts
    this.reconnectAttempts = 0;
    
    // Emit connect event
    this.eventEmitter.emit(WebSocketEvent.CONNECT);
  }
  
  /**
   * Handle WebSocket message event
   * @param event Message event
   */
  private handleMessage(event: MessageEvent): void {
    try {
      const data = JSON.parse(event.data);
      
      // Emit event based on message type
      if (data.type) {
        this.eventEmitter.emit(data.type, data.payload);
      }
    } catch (error) {
      console.error('Error parsing WebSocket message:', error);
    }
  }
  
  /**
   * Handle WebSocket close event
   * @param event Close event
   */
  private handleClose(event: CloseEvent): void {
    console.log('WebSocket disconnected:', event.code, event.reason);
    
    // Clear ping interval
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
      this.pingInterval = null;
    }
    
    // Attempt to reconnect if not a normal closure
    if (event.code !== 1000 && event.code !== 1001) {
      this.attemptReconnect();
    }
    
    // Emit disconnect event
    this.eventEmitter.emit(WebSocketEvent.DISCONNECT);
  }
  
  /**
   * Handle WebSocket error event
   * @param event Error event
   */
  private handleError(event: Event): void {
    console.error('WebSocket error:', event);
    
    // Emit error event
    this.eventEmitter.emit(WebSocketEvent.ERROR, event);
  }
  
  /**
   * Attempt to reconnect to the WebSocket server
   */
  private attemptReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnect attempts reached');
      return;
    }
    
    // Increment reconnect attempts
    this.reconnectAttempts++;
    
    // Calculate exponential backoff
    const timeout = Math.min(30000, this.reconnectTimeout * Math.pow(2, this.reconnectAttempts - 1));
    
    console.log(`Attempting to reconnect in ${timeout}ms (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
    
    // Set reconnect timer
    this.reconnectTimer = setTimeout(() => {
      if (this.userId) {
        // Reconnect with the same user ID
        this.connect(this.userId, ''); // Token will need to be refreshed
      }
    }, timeout);
  }
  
  /**
   * Start ping interval to keep connection alive
   */
  private startPingInterval(): void {
    // Clear existing interval
    if (this.pingInterval) {
      clearInterval(this.pingInterval);
    }
    
    // Send ping every 30 seconds
    this.pingInterval = setInterval(() => {
      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(JSON.stringify({ type: 'ping' }));
      }
    }, 30000);
  }
}

// Export a singleton instance
export default new WebSocketService();
