/**
 * Rating service for the Chinese Chess application
 * Implements the Elo rating system for player ratings
 */
import firestore from '@react-native-firebase/firestore';
import { store } from '../../store';
import { setError } from '../../store/slices/gameSlice';

/**
 * Player rating type
 */
export interface PlayerRating {
  userId: string;
  displayName: string;
  rating: number;
  gamesPlayed: number;
  gamesWon: number;
  gamesLost: number;
  gamesDraw: number;
  lastPlayed: number;
  ratingHistory: {
    date: number;
    rating: number;
    change: number;
    opponentId: string;
    opponentName: string;
    opponentRating: number;
    result: 'win' | 'loss' | 'draw';
  }[];
}

/**
 * Leaderboard entry type
 */
export interface LeaderboardEntry {
  userId: string;
  displayName: string;
  rating: number;
  gamesPlayed: number;
  winRate: number;
  rank: number;
}

/**
 * Rating service class
 */
class RatingService {
  private readonly DEFAULT_RATING = 1200;
  private readonly K_FACTOR = 32; // Standard K-factor for Elo rating
  private readonly K_FACTOR_PROVISIONAL = 64; // Higher K-factor for new players (< 30 games)
  private readonly PROVISIONAL_GAMES_THRESHOLD = 30;
  
  /**
   * Calculate the expected score for a player
   * @param playerRating Player's rating
   * @param opponentRating Opponent's rating
   * @returns Expected score (between 0 and 1)
   */
  calculateExpectedScore(playerRating: number, opponentRating: number): number {
    return 1 / (1 + Math.pow(10, (opponentRating - playerRating) / 400));
  }
  
  /**
   * Calculate the new rating for a player
   * @param playerRating Player's current rating
   * @param opponentRating Opponent's rating
   * @param actualScore Actual score (1 for win, 0.5 for draw, 0 for loss)
   * @param gamesPlayed Number of games the player has played
   * @returns New rating
   */
  calculateNewRating(
    playerRating: number,
    opponentRating: number,
    actualScore: number,
    gamesPlayed: number
  ): number {
    // Calculate expected score
    const expectedScore = this.calculateExpectedScore(playerRating, opponentRating);
    
    // Determine K-factor based on number of games played
    const kFactor = gamesPlayed < this.PROVISIONAL_GAMES_THRESHOLD
      ? this.K_FACTOR_PROVISIONAL
      : this.K_FACTOR;
    
    // Calculate rating change
    const ratingChange = Math.round(kFactor * (actualScore - expectedScore));
    
    // Return new rating
    return playerRating + ratingChange;
  }
  
  /**
   * Update ratings after a game
   * @param winnerId Winner user ID (null for draw)
   * @param loserId Loser user ID (null for draw)
   * @param isDraw Whether the game was a draw
   * @returns Promise with updated ratings
   */
  async updateRatings(
    player1Id: string,
    player2Id: string,
    winnerId: string | null
  ): Promise<{ player1NewRating: number; player2NewRating: number }> {
    try {
      // Get player ratings
      const player1Data = await this.getPlayerRating(player1Id);
      const player2Data = await this.getPlayerRating(player2Id);
      
      // Determine actual scores
      let player1Score: number;
      let player2Score: number;
      
      if (winnerId === null) {
        // Draw
        player1Score = 0.5;
        player2Score = 0.5;
      } else if (winnerId === player1Id) {
        // Player 1 won
        player1Score = 1;
        player2Score = 0;
      } else {
        // Player 2 won
        player1Score = 0;
        player2Score = 1;
      }
      
      // Calculate new ratings
      const player1NewRating = this.calculateNewRating(
        player1Data.rating,
        player2Data.rating,
        player1Score,
        player1Data.gamesPlayed
      );
      
      const player2NewRating = this.calculateNewRating(
        player2Data.rating,
        player1Data.rating,
        player2Score,
        player2Data.gamesPlayed
      );
      
      // Update player 1 stats
      const player1Update: Partial<PlayerRating> = {
        rating: player1NewRating,
        gamesPlayed: player1Data.gamesPlayed + 1,
        lastPlayed: Date.now(),
      };
      
      if (player1Score === 1) {
        player1Update.gamesWon = player1Data.gamesWon + 1;
      } else if (player1Score === 0) {
        player1Update.gamesLost = player1Data.gamesLost + 1;
      } else {
        player1Update.gamesDraw = player1Data.gamesDraw + 1;
      }
      
      // Update player 2 stats
      const player2Update: Partial<PlayerRating> = {
        rating: player2NewRating,
        gamesPlayed: player2Data.gamesPlayed + 1,
        lastPlayed: Date.now(),
      };
      
      if (player2Score === 1) {
        player2Update.gamesWon = player2Data.gamesWon + 1;
      } else if (player2Score === 0) {
        player2Update.gamesLost = player2Data.gamesLost + 1;
      } else {
        player2Update.gamesDraw = player2Data.gamesDraw + 1;
      }
      
      // Add rating history entry for player 1
      const player1HistoryEntry = {
        date: Date.now(),
        rating: player1NewRating,
        change: player1NewRating - player1Data.rating,
        opponentId: player2Id,
        opponentName: player2Data.displayName,
        opponentRating: player2Data.rating,
        result: player1Score === 1 ? 'win' : player1Score === 0 ? 'loss' : 'draw' as 'win' | 'loss' | 'draw',
      };
      
      // Add rating history entry for player 2
      const player2HistoryEntry = {
        date: Date.now(),
        rating: player2NewRating,
        change: player2NewRating - player2Data.rating,
        opponentId: player1Id,
        opponentName: player1Data.displayName,
        opponentRating: player1Data.rating,
        result: player2Score === 1 ? 'win' : player2Score === 0 ? 'loss' : 'draw' as 'win' | 'loss' | 'draw',
      };
      
      // Update player 1 in Firestore
      await firestore()
        .collection('ratings')
        .doc(player1Id)
        .update({
          ...player1Update,
          ratingHistory: firestore.FieldValue.arrayUnion(player1HistoryEntry),
        });
      
      // Update player 2 in Firestore
      await firestore()
        .collection('ratings')
        .doc(player2Id)
        .update({
          ...player2Update,
          ratingHistory: firestore.FieldValue.arrayUnion(player2HistoryEntry),
        });
      
      return {
        player1NewRating,
        player2NewRating,
      };
    } catch (error) {
      console.error('Error updating ratings:', error);
      store.dispatch(setError('Failed to update ratings'));
      throw error;
    }
  }
  
  /**
   * Get a player's rating
   * @param userId User ID
   * @returns Promise with player rating
   */
  async getPlayerRating(userId: string): Promise<PlayerRating> {
    try {
      // Get player rating from Firestore
      const doc = await firestore()
        .collection('ratings')
        .doc(userId)
        .get();
      
      if (doc.exists) {
        return doc.data() as PlayerRating;
      }
      
      // If player doesn't have a rating yet, get user data and create a new rating
      const userDoc = await firestore()
        .collection('users')
        .doc(userId)
        .get();
      
      if (!userDoc.exists) {
        throw new Error('User not found');
      }
      
      const userData = userDoc.data();
      
      // Create new rating
      const newRating: PlayerRating = {
        userId,
        displayName: userData?.displayName || 'Unknown Player',
        rating: this.DEFAULT_RATING,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        gamesDraw: 0,
        lastPlayed: 0,
        ratingHistory: [],
      };
      
      // Save new rating to Firestore
      await firestore()
        .collection('ratings')
        .doc(userId)
        .set(newRating);
      
      return newRating;
    } catch (error) {
      console.error('Error getting player rating:', error);
      store.dispatch(setError('Failed to get player rating'));
      throw error;
    }
  }
  
  /**
   * Get the leaderboard
   * @param limit Number of players to return
   * @returns Promise with leaderboard entries
   */
  async getLeaderboard(limit: number = 100): Promise<LeaderboardEntry[]> {
    try {
      // Get top players from Firestore
      const snapshot = await firestore()
        .collection('ratings')
        .where('gamesPlayed', '>=', 5) // Only include players with at least 5 games
        .orderBy('gamesPlayed', 'desc')
        .orderBy('rating', 'desc')
        .limit(limit)
        .get();
      
      // Map to leaderboard entries
      const leaderboard = snapshot.docs.map((doc, index) => {
        const data = doc.data() as PlayerRating;
        
        return {
          userId: data.userId,
          displayName: data.displayName,
          rating: data.rating,
          gamesPlayed: data.gamesPlayed,
          winRate: data.gamesPlayed > 0
            ? Math.round((data.gamesWon / data.gamesPlayed) * 100)
            : 0,
          rank: index + 1,
        } as LeaderboardEntry;
      });
      
      return leaderboard;
    } catch (error) {
      console.error('Error getting leaderboard:', error);
      store.dispatch(setError('Failed to get leaderboard'));
      return [];
    }
  }
  
  /**
   * Get a player's rating history
   * @param userId User ID
   * @returns Promise with rating history
   */
  async getRatingHistory(userId: string): Promise<PlayerRating['ratingHistory']> {
    try {
      // Get player rating from Firestore
      const doc = await firestore()
        .collection('ratings')
        .doc(userId)
        .get();
      
      if (doc.exists) {
        const data = doc.data() as PlayerRating;
        return data.ratingHistory || [];
      }
      
      return [];
    } catch (error) {
      console.error('Error getting rating history:', error);
      store.dispatch(setError('Failed to get rating history'));
      return [];
    }
  }
  
  /**
   * Get a player's rank
   * @param userId User ID
   * @returns Promise with player rank
   */
  async getPlayerRank(userId: string): Promise<number> {
    try {
      // Get player rating
      const playerRating = await this.getPlayerRating(userId);
      
      // Count players with higher rating
      const snapshot = await firestore()
        .collection('ratings')
        .where('rating', '>', playerRating.rating)
        .where('gamesPlayed', '>=', 5) // Only include players with at least 5 games
        .get();
      
      // Return rank (1-based)
      return snapshot.size + 1;
    } catch (error) {
      console.error('Error getting player rank:', error);
      store.dispatch(setError('Failed to get player rank'));
      return 0;
    }
  }
}

// Export a singleton instance
export default new RatingService();
