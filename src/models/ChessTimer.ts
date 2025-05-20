/**
 * Enum representing the possible states of a chess timer
 */
export enum TimerState {
  READY = 'ready',
  RUNNING = 'running',
  PAUSED = 'paused',
  EXPIRED = 'expired',
  STOPPED = 'stopped',
}

/**
 * Class representing a chess timer for a single player
 */
export class ChessTimer {
  private initialTimeSeconds: number;
  private incrementSeconds: number;
  private timeRemainingSeconds: number;
  private timerState: TimerState;
  private timerInterval: NodeJS.Timeout | null;
  private lastUpdateTime: Date | null;
  private listeners: Array<() => void>;

  /**
   * Constructor for ChessTimer
   * @param initialTimeSeconds Initial time in seconds (default: 180 seconds = 3 minutes)
   * @param incrementSeconds Time increment in seconds after each move (default: 2 seconds)
   */
  constructor(initialTimeSeconds: number = 180, incrementSeconds: number = 2) {
    this.initialTimeSeconds = initialTimeSeconds;
    this.incrementSeconds = incrementSeconds;
    this.timeRemainingSeconds = initialTimeSeconds;
    this.timerState = TimerState.READY;
    this.timerInterval = null;
    this.lastUpdateTime = null;
    this.listeners = [];
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
   * Start the timer
   */
  start(): void {
    if (this.timerState === TimerState.RUNNING) {
      return;
    }

    this.timerState = TimerState.RUNNING;
    this.lastUpdateTime = new Date();

    // Clear any existing interval
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }

    // Update the timer every 100ms for smooth display
    this.timerInterval = setInterval(() => {
      if (this.timerState !== TimerState.RUNNING) {
        return;
      }

      const now = new Date();
      if (this.lastUpdateTime) {
        const elapsedSeconds = (now.getTime() - this.lastUpdateTime.getTime()) / 1000;
        this.timeRemainingSeconds -= elapsedSeconds;

        // Check if timer has expired
        if (this.timeRemainingSeconds <= 0) {
          this.timeRemainingSeconds = 0;
          this.timerState = TimerState.EXPIRED;
          this.stop();
        }
      }

      this.lastUpdateTime = now;
      this.notifyListeners();
    }, 100);

    this.notifyListeners();
  }

  /**
   * Pause the timer
   */
  pause(): void {
    if (this.timerState !== TimerState.RUNNING) {
      return;
    }

    this.timerState = TimerState.PAUSED;
    this.lastUpdateTime = null;

    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }

    this.notifyListeners();
  }

  /**
   * Stop the timer
   */
  stop(): void {
    this.timerState = TimerState.STOPPED;
    this.lastUpdateTime = null;

    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }

    this.notifyListeners();
  }

  /**
   * Reset the timer to initial time
   */
  reset(): void {
    this.timeRemainingSeconds = this.initialTimeSeconds;
    this.timerState = TimerState.READY;
    this.lastUpdateTime = null;

    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }

    this.notifyListeners();
  }

  /**
   * Add increment time after a move
   */
  addIncrement(): void {
    this.timeRemainingSeconds += this.incrementSeconds;
    this.notifyListeners();
  }

  /**
   * Set the time remaining
   * @param seconds Time in seconds
   */
  setTimeRemaining(seconds: number): void {
    this.timeRemainingSeconds = seconds;
    this.notifyListeners();
  }

  /**
   * Get the time remaining in seconds
   */
  getTimeRemaining(): number {
    return this.timeRemainingSeconds;
  }

  /**
   * Get the timer state
   */
  getState(): TimerState {
    return this.timerState;
  }

  /**
   * Check if the timer has expired
   */
  isExpired(): boolean {
    return this.timerState === TimerState.EXPIRED;
  }

  /**
   * Get formatted time string (mm:ss)
   */
  getFormattedTime(): string {
    const minutes = Math.floor(this.timeRemainingSeconds / 60);
    const seconds = Math.floor(this.timeRemainingSeconds % 60);
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * Clean up resources
   */
  dispose(): void {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
    this.listeners = [];
  }
}
