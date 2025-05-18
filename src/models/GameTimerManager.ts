import { ChessTimer, TimerState } from './ChessTimer';

/**
 * Class for managing both player timers in a chess game
 */
export class GameTimerManager {
  private redTimer: ChessTimer;
  private blackTimer: ChessTimer;
  private currentPlayer: 'red' | 'black';
  private enabled: boolean;
  private listeners: Array<() => void>;

  /**
   * Constructor for GameTimerManager
   * @param initialTimeSeconds Initial time in seconds (default: 180 seconds = 3 minutes)
   * @param incrementSeconds Time increment in seconds after each move (default: 2 seconds)
   */
  constructor(initialTimeSeconds: number = 180, incrementSeconds: number = 2) {
    this.redTimer = new ChessTimer(initialTimeSeconds, incrementSeconds);
    this.blackTimer = new ChessTimer(initialTimeSeconds, incrementSeconds);
    this.currentPlayer = 'red';
    this.enabled = false;
    this.listeners = [];

    // Add listeners to both timers
    this.redTimer.addListener(() => this.notifyListeners());
    this.blackTimer.addListener(() => this.notifyListeners());
  }

  /**
   * Add a listener to be notified of timer changes
   * @param listener Function to call when timer changes
   */
  addListener(listener: () => void): void {
    this.listeners.push(listener);
  }

  /**
   * Remove a listener
   * @param listener Function to remove
   */
  removeListener(listener: () => void): void {
    this.listeners = this.listeners.filter(l => l !== listener);
  }

  /**
   * Notify all listeners of a change
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => listener());
  }

  /**
   * Get the timer for a specific player
   * @param player Player color ('red' or 'black')
   */
  getTimerForPlayer(player: 'red' | 'black'): ChessTimer {
    return player === 'red' ? this.redTimer : this.blackTimer;
  }

  /**
   * Start a new game with fresh timers
   */
  startNewGame(): void {
    this.redTimer.reset();
    this.blackTimer.reset();
    this.currentPlayer = 'red';
    
    if (this.enabled) {
      this.redTimer.start();
      this.blackTimer.pause();
    }
    
    this.notifyListeners();
  }

  /**
   * Switch the active player
   * @param player New active player ('red' or 'black')
   */
  switchPlayer(player: 'red' | 'black'): void {
    if (!this.enabled) {
      return;
    }

    this.currentPlayer = player;
    
    // Add increment to the player who just moved
    const previousPlayer = player === 'red' ? 'black' : 'red';
    this.getTimerForPlayer(previousPlayer).addIncrement();
    
    // Pause previous player's timer and start current player's timer
    this.getTimerForPlayer(previousPlayer).pause();
    this.getTimerForPlayer(player).start();
    
    this.notifyListeners();
  }

  /**
   * Set the time remaining for a specific player
   * @param player Player color ('red' or 'black')
   * @param seconds Time in seconds
   */
  setTimeRemaining(player: 'red' | 'black', seconds: number): void {
    this.getTimerForPlayer(player).setTimeRemaining(seconds);
  }

  /**
   * Pause both timers
   */
  pauseAll(): void {
    this.redTimer.pause();
    this.blackTimer.pause();
    this.notifyListeners();
  }

  /**
   * Resume the current player's timer
   */
  resumeCurrent(): void {
    if (!this.enabled) {
      return;
    }
    
    this.getTimerForPlayer(this.currentPlayer).start();
    this.notifyListeners();
  }

  /**
   * Enable or disable the timer
   * @param enabled Whether the timer is enabled
   */
  setEnabled(enabled: boolean): void {
    this.enabled = enabled;
    
    if (enabled) {
      // Start the current player's timer
      this.getTimerForPlayer(this.currentPlayer).start();
    } else {
      // Pause both timers
      this.pauseAll();
    }
    
    this.notifyListeners();
  }

  /**
   * Check if the timer is enabled
   */
  isEnabled(): boolean {
    return this.enabled;
  }

  /**
   * Get the current active player
   */
  getCurrentPlayer(): 'red' | 'black' {
    return this.currentPlayer;
  }

  /**
   * Check if a player's timer has expired
   * @param player Player color ('red' or 'black')
   */
  isPlayerTimerExpired(player: 'red' | 'black'): boolean {
    return this.getTimerForPlayer(player).isExpired();
  }

  /**
   * Clean up resources
   */
  dispose(): void {
    this.redTimer.dispose();
    this.blackTimer.dispose();
    this.listeners = [];
  }
}
