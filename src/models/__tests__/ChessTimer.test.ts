import { ChessTimer, TimerState } from '../ChessTimer';

// Mock timers
jest.useFakeTimers();

describe('ChessTimer', () => {
  let timer: ChessTimer;
  
  beforeEach(() => {
    timer = new ChessTimer(180, 2);
  });
  
  afterEach(() => {
    timer.dispose();
  });
  
  it('initializes with correct values', () => {
    expect(timer.getTimeRemaining()).toBe(180);
    expect(timer.getState()).toBe(TimerState.READY);
    expect(timer.isExpired()).toBe(false);
    expect(timer.getFormattedTime()).toBe('03:00');
  });
  
  it('starts and updates time correctly', () => {
    // Start the timer
    timer.start();
    expect(timer.getState()).toBe(TimerState.RUNNING);
    
    // Advance time by 10 seconds
    jest.advanceTimersByTime(10000);
    
    // Time should be reduced by approximately 10 seconds
    expect(timer.getTimeRemaining()).toBeLessThanOrEqual(170);
    expect(timer.getTimeRemaining()).toBeGreaterThan(169);
  });
  
  it('pauses correctly', () => {
    // Start the timer
    timer.start();
    
    // Advance time by 10 seconds
    jest.advanceTimersByTime(10000);
    
    // Pause the timer
    timer.pause();
    expect(timer.getState()).toBe(TimerState.PAUSED);
    
    // Record the time
    const timeAfterPause = timer.getTimeRemaining();
    
    // Advance time by another 10 seconds
    jest.advanceTimersByTime(10000);
    
    // Time should not have changed
    expect(timer.getTimeRemaining()).toBe(timeAfterPause);
  });
  
  it('adds increment correctly', () => {
    // Start the timer
    timer.start();
    
    // Advance time by 10 seconds
    jest.advanceTimersByTime(10000);
    
    // Record the time
    const timeBeforeIncrement = timer.getTimeRemaining();
    
    // Add increment
    timer.addIncrement();
    
    // Time should be increased by 2 seconds
    expect(timer.getTimeRemaining()).toBeCloseTo(timeBeforeIncrement + 2, 1);
  });
  
  it('expires when time runs out', () => {
    // Set time to 1 second
    timer.setTimeRemaining(1);
    
    // Start the timer
    timer.start();
    
    // Advance time by 2 seconds
    jest.advanceTimersByTime(2000);
    
    // Timer should be expired
    expect(timer.isExpired()).toBe(true);
    expect(timer.getState()).toBe(TimerState.EXPIRED);
    expect(timer.getTimeRemaining()).toBe(0);
  });
  
  it('resets correctly', () => {
    // Start the timer
    timer.start();
    
    // Advance time by 10 seconds
    jest.advanceTimersByTime(10000);
    
    // Reset the timer
    timer.reset();
    
    // Timer should be back to initial state
    expect(timer.getTimeRemaining()).toBe(180);
    expect(timer.getState()).toBe(TimerState.READY);
    expect(timer.isExpired()).toBe(false);
  });
  
  it('notifies listeners of changes', () => {
    const listener = jest.fn();
    
    // Add listener
    timer.addListener(listener);
    
    // Start the timer (should trigger listener)
    timer.start();
    expect(listener).toHaveBeenCalled();
    
    // Reset listener count
    listener.mockClear();
    
    // Pause the timer (should trigger listener)
    timer.pause();
    expect(listener).toHaveBeenCalled();
    
    // Reset listener count
    listener.mockClear();
    
    // Remove listener
    timer.removeListener(listener);
    
    // Reset the timer (should not trigger listener)
    timer.reset();
    expect(listener).not.toHaveBeenCalled();
  });
});
