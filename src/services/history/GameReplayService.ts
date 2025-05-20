/**
 * Game replay service for the Chinese Chess application
 */
import { EventEmitter } from 'events';
import { store } from '../../store';
import { 
  setPieces, 
  setCurrentPlayer, 
  setFenString,
  setError
} from '../../store/slices/gameSlice';
import { gameService } from '../game';
import { Move } from '../game/Board';
import { GameHistoryEntry } from './GameHistoryService';

/**
 * Replay event types
 */
export enum ReplayEvent {
  MOVE_CHANGED = 'move_changed',
  REPLAY_STARTED = 'replay_started',
  REPLAY_PAUSED = 'replay_paused',
  REPLAY_RESUMED = 'replay_resumed',
  REPLAY_STOPPED = 'replay_stopped',
  REPLAY_COMPLETED = 'replay_completed',
}

/**
 * Game replay service class
 */
class GameReplayService {
  private eventEmitter: EventEmitter;
  private currentGame: GameHistoryEntry | null = null;
  private currentMoveIndex: number = -1;
  private isPlaying: boolean = false;
  private replayInterval: NodeJS.Timeout | null = null;
  private replaySpeed: number = 1000; // 1 second per move
  
  /**
   * Constructor
   */
  constructor() {
    this.eventEmitter = new EventEmitter();
  }
  
  /**
   * Load a game for replay
   * @param game Game history entry
   */
  loadGame(game: GameHistoryEntry): void {
    // Stop any existing replay
    this.stopReplay();
    
    // Set the current game
    this.currentGame = game;
    
    // Reset the move index
    this.currentMoveIndex = -1;
    
    // Initialize the game with the starting position
    gameService.initGame('free');
    
    // Update the Redux store
    store.dispatch(setPieces(gameService.getBoardState()));
    store.dispatch(setCurrentPlayer('red'));
    store.dispatch(setFenString(gameService.getFen()));
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.MOVE_CHANGED, {
      moveIndex: this.currentMoveIndex,
      totalMoves: game.moves.length,
    });
  }
  
  /**
   * Start or resume the replay
   */
  startReplay(): void {
    if (!this.currentGame) {
      console.error('No game loaded');
      store.dispatch(setError('No game loaded for replay'));
      return;
    }
    
    if (this.isPlaying) {
      return;
    }
    
    this.isPlaying = true;
    
    // Emit event
    if (this.currentMoveIndex === -1) {
      this.eventEmitter.emit(ReplayEvent.REPLAY_STARTED);
    } else {
      this.eventEmitter.emit(ReplayEvent.REPLAY_RESUMED);
    }
    
    // Start the replay interval
    this.replayInterval = setInterval(() => {
      this.nextMove();
      
      // Stop if we've reached the end
      if (this.currentMoveIndex >= this.currentGame!.moves.length - 1) {
        this.pauseReplay();
        this.eventEmitter.emit(ReplayEvent.REPLAY_COMPLETED);
      }
    }, this.replaySpeed);
  }
  
  /**
   * Pause the replay
   */
  pauseReplay(): void {
    if (!this.isPlaying) {
      return;
    }
    
    this.isPlaying = false;
    
    // Clear the interval
    if (this.replayInterval) {
      clearInterval(this.replayInterval);
      this.replayInterval = null;
    }
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.REPLAY_PAUSED);
  }
  
  /**
   * Stop the replay
   */
  stopReplay(): void {
    // Pause the replay
    this.pauseReplay();
    
    // Reset the state
    this.currentGame = null;
    this.currentMoveIndex = -1;
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.REPLAY_STOPPED);
  }
  
  /**
   * Go to the next move
   */
  nextMove(): void {
    if (!this.currentGame) {
      console.error('No game loaded');
      store.dispatch(setError('No game loaded for replay'));
      return;
    }
    
    if (this.currentMoveIndex >= this.currentGame.moves.length - 1) {
      return;
    }
    
    // Increment the move index
    this.currentMoveIndex++;
    
    // Get the move
    const move = this.currentGame.moves[this.currentMoveIndex];
    
    // Make the move
    this.makeMove(move);
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.MOVE_CHANGED, {
      moveIndex: this.currentMoveIndex,
      totalMoves: this.currentGame.moves.length,
      move,
    });
  }
  
  /**
   * Go to the previous move
   */
  previousMove(): void {
    if (!this.currentGame) {
      console.error('No game loaded');
      store.dispatch(setError('No game loaded for replay'));
      return;
    }
    
    if (this.currentMoveIndex <= 0) {
      // If we're at the first move, go back to the starting position
      if (this.currentMoveIndex === 0) {
        this.currentMoveIndex = -1;
        
        // Reset the game
        gameService.initGame('free');
        
        // Update the Redux store
        store.dispatch(setPieces(gameService.getBoardState()));
        store.dispatch(setCurrentPlayer('red'));
        store.dispatch(setFenString(gameService.getFen()));
        
        // Emit event
        this.eventEmitter.emit(ReplayEvent.MOVE_CHANGED, {
          moveIndex: this.currentMoveIndex,
          totalMoves: this.currentGame.moves.length,
        });
      }
      
      return;
    }
    
    // Decrement the move index
    this.currentMoveIndex--;
    
    // Reset the game
    gameService.initGame('free');
    
    // Replay all moves up to the current index
    for (let i = 0; i <= this.currentMoveIndex; i++) {
      this.makeMove(this.currentGame.moves[i], false);
    }
    
    // Update the Redux store
    store.dispatch(setPieces(gameService.getBoardState()));
    store.dispatch(setCurrentPlayer(this.currentMoveIndex % 2 === 0 ? 'black' : 'red'));
    store.dispatch(setFenString(gameService.getFen()));
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.MOVE_CHANGED, {
      moveIndex: this.currentMoveIndex,
      totalMoves: this.currentGame.moves.length,
      move: this.currentGame.moves[this.currentMoveIndex],
    });
  }
  
  /**
   * Go to a specific move
   * @param moveIndex Move index
   */
  goToMove(moveIndex: number): void {
    if (!this.currentGame) {
      console.error('No game loaded');
      store.dispatch(setError('No game loaded for replay'));
      return;
    }
    
    if (moveIndex < -1 || moveIndex >= this.currentGame.moves.length) {
      console.error('Invalid move index');
      store.dispatch(setError('Invalid move index'));
      return;
    }
    
    // Reset the game
    gameService.initGame('free');
    
    // Set the move index
    this.currentMoveIndex = moveIndex;
    
    // Replay all moves up to the current index
    for (let i = 0; i <= moveIndex; i++) {
      this.makeMove(this.currentGame.moves[i], false);
    }
    
    // Update the Redux store
    store.dispatch(setPieces(gameService.getBoardState()));
    store.dispatch(setCurrentPlayer(moveIndex % 2 === 0 ? 'black' : 'red'));
    store.dispatch(setFenString(gameService.getFen()));
    
    // Emit event
    this.eventEmitter.emit(ReplayEvent.MOVE_CHANGED, {
      moveIndex: this.currentMoveIndex,
      totalMoves: this.currentGame.moves.length,
      move: moveIndex >= 0 ? this.currentGame.moves[moveIndex] : undefined,
    });
  }
  
  /**
   * Set the replay speed
   * @param speed Speed in milliseconds per move
   */
  setReplaySpeed(speed: number): void {
    this.replaySpeed = speed;
    
    // If we're playing, restart the interval with the new speed
    if (this.isPlaying) {
      this.pauseReplay();
      this.startReplay();
    }
  }
  
  /**
   * Get the current move index
   * @returns Current move index
   */
  getCurrentMoveIndex(): number {
    return this.currentMoveIndex;
  }
  
  /**
   * Get the total number of moves
   * @returns Total number of moves
   */
  getTotalMoves(): number {
    return this.currentGame ? this.currentGame.moves.length : 0;
  }
  
  /**
   * Check if the replay is playing
   * @returns True if playing, false otherwise
   */
  isReplayPlaying(): boolean {
    return this.isPlaying;
  }
  
  /**
   * Add an event listener
   * @param event Event type
   * @param listener Event listener
   */
  on(event: ReplayEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.on(event, listener);
  }
  
  /**
   * Remove an event listener
   * @param event Event type
   * @param listener Event listener
   */
  off(event: ReplayEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.off(event, listener);
  }
  
  /**
   * Make a move
   * @param move Move to make
   * @param updateStore Whether to update the Redux store
   */
  private makeMove(move: Move, updateStore: boolean = true): void {
    // Make the move
    gameService.makeMove(
      move.from.row,
      move.from.col,
      move.to.row,
      move.to.col
    );
    
    // Update the Redux store if needed
    if (updateStore) {
      store.dispatch(setPieces(gameService.getBoardState()));
      store.dispatch(setCurrentPlayer(this.currentMoveIndex % 2 === 0 ? 'black' : 'red'));
      store.dispatch(setFenString(gameService.getFen()));
    }
  }
}

// Export a singleton instance
export default new GameReplayService();
