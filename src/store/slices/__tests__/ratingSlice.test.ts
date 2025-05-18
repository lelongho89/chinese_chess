import ratingReducer, {
  setPlayerRating,
  setLeaderboard,
  setRatingHistory,
  setPlayerRank,
  updateUserStats,
  setLoading,
  setError,
  resetRating,
} from '../ratingSlice';
import { PlayerRating, LeaderboardEntry } from '../../services/rating';

describe('Rating Slice', () => {
  // Initial state test
  it('should return the initial state', () => {
    const initialState = ratingReducer(undefined, { type: undefined });
    
    expect(initialState.playerRating).toBeNull();
    expect(initialState.leaderboard).toEqual([]);
    expect(initialState.ratingHistory).toEqual([]);
    expect(initialState.playerRank).toBe(0);
    expect(initialState.isLoading).toBe(false);
    expect(initialState.error).toBeNull();
  });
  
  // Test setPlayerRating action
  it('should handle setPlayerRating', () => {
    const playerRating: PlayerRating = {
      userId: 'test-user-id',
      displayName: 'Test User',
      rating: 1500,
      gamesPlayed: 10,
      gamesWon: 6,
      gamesLost: 3,
      gamesDraw: 1,
      lastPlayed: Date.now(),
      ratingHistory: [],
    };
    
    const initialState = ratingReducer(undefined, { type: undefined });
    const nextState = ratingReducer(initialState, setPlayerRating(playerRating));
    
    expect(nextState.playerRating).toEqual(playerRating);
  });
  
  // Test setLeaderboard action
  it('should handle setLeaderboard', () => {
    const leaderboard: LeaderboardEntry[] = [
      {
        userId: 'user1',
        displayName: 'User 1',
        rating: 1800,
        gamesPlayed: 20,
        winRate: 75,
        rank: 1,
      },
      {
        userId: 'user2',
        displayName: 'User 2',
        rating: 1700,
        gamesPlayed: 15,
        winRate: 60,
        rank: 2,
      },
    ];
    
    const initialState = ratingReducer(undefined, { type: undefined });
    const nextState = ratingReducer(initialState, setLeaderboard(leaderboard));
    
    expect(nextState.leaderboard).toEqual(leaderboard);
  });
  
  // Test setRatingHistory action
  it('should handle setRatingHistory', () => {
    const ratingHistory = [
      {
        date: Date.now() - 86400000, // 1 day ago
        rating: 1450,
        change: 50,
        opponentId: 'opponent1',
        opponentName: 'Opponent 1',
        opponentRating: 1500,
        result: 'win' as 'win',
      },
      {
        date: Date.now(),
        rating: 1500,
        change: 50,
        opponentId: 'opponent2',
        opponentName: 'Opponent 2',
        opponentRating: 1600,
        result: 'win' as 'win',
      },
    ];
    
    const initialState = ratingReducer(undefined, { type: undefined });
    const nextState = ratingReducer(initialState, setRatingHistory(ratingHistory));
    
    expect(nextState.ratingHistory).toEqual(ratingHistory);
  });
  
  // Test setPlayerRank action
  it('should handle setPlayerRank', () => {
    const initialState = ratingReducer(undefined, { type: undefined });
    const nextState = ratingReducer(initialState, setPlayerRank(5));
    
    expect(nextState.playerRank).toBe(5);
  });
  
  // Test updateUserStats action
  it('should handle updateUserStats', () => {
    // Start with a state that has player rating
    const playerRating: PlayerRating = {
      userId: 'test-user-id',
      displayName: 'Test User',
      rating: 1500,
      gamesPlayed: 10,
      gamesWon: 6,
      gamesLost: 3,
      gamesDraw: 1,
      lastPlayed: Date.now(),
      ratingHistory: [],
    };
    
    const initialState = ratingReducer(undefined, setPlayerRating(playerRating));
    
    // Update user stats
    const updatedStats = {
      rating: 1550,
      gamesPlayed: 11,
      gamesWon: 7,
      gamesLost: 3,
      gamesDraw: 1,
    };
    
    const nextState = ratingReducer(initialState, updateUserStats(updatedStats));
    
    // Check that the stats were updated
    expect(nextState.playerRating).not.toBeNull();
    if (nextState.playerRating) {
      expect(nextState.playerRating.rating).toBe(1550);
      expect(nextState.playerRating.gamesPlayed).toBe(11);
      expect(nextState.playerRating.gamesWon).toBe(7);
      expect(nextState.playerRating.gamesLost).toBe(3);
      expect(nextState.playerRating.gamesDraw).toBe(1);
      
      // Other properties should remain unchanged
      expect(nextState.playerRating.userId).toBe('test-user-id');
      expect(nextState.playerRating.displayName).toBe('Test User');
      expect(nextState.playerRating.lastPlayed).toBe(playerRating.lastPlayed);
    }
  });
  
  // Test setLoading action
  it('should handle setLoading', () => {
    const initialState = ratingReducer(undefined, { type: undefined });
    
    // Set loading to true
    const loadingState = ratingReducer(initialState, setLoading(true));
    expect(loadingState.isLoading).toBe(true);
    
    // Set loading to false
    const notLoadingState = ratingReducer(loadingState, setLoading(false));
    expect(notLoadingState.isLoading).toBe(false);
  });
  
  // Test setError action
  it('should handle setError', () => {
    const error = 'Failed to load rating data';
    
    const initialState = ratingReducer(undefined, { type: undefined });
    const errorState = ratingReducer(initialState, setError(error));
    
    expect(errorState.error).toBe(error);
    expect(errorState.isLoading).toBe(false);
  });
  
  // Test resetRating action
  it('should handle resetRating', () => {
    // Start with a populated state
    let state = ratingReducer(undefined, { type: undefined });
    
    const playerRating: PlayerRating = {
      userId: 'test-user-id',
      displayName: 'Test User',
      rating: 1500,
      gamesPlayed: 10,
      gamesWon: 6,
      gamesLost: 3,
      gamesDraw: 1,
      lastPlayed: Date.now(),
      ratingHistory: [],
    };
    
    state = ratingReducer(state, setPlayerRating(playerRating));
    state = ratingReducer(state, setPlayerRank(5));
    state = ratingReducer(state, setError('Some error'));
    
    // Reset rating
    const resetState = ratingReducer(state, resetRating());
    
    // Check that all state is reset
    expect(resetState.playerRating).toBeNull();
    expect(resetState.leaderboard).toEqual([]);
    expect(resetState.ratingHistory).toEqual([]);
    expect(resetState.playerRank).toBe(0);
    expect(resetState.isLoading).toBe(false);
    expect(resetState.error).toBeNull();
  });
});
