/**
 * Matchmaking service for online play
 */
import { EventEmitter } from 'events';
import firestore from '@react-native-firebase/firestore';
import { store } from '../../store';
import { setError } from '../../store/slices/gameSlice';
import GameSyncService, { OnlineGame } from './GameSyncService';

// Matchmaking event types
export enum MatchmakingEvent {
  QUEUE_JOINED = 'queue_joined',
  QUEUE_LEFT = 'queue_left',
  MATCH_FOUND = 'match_found',
  MATCH_ACCEPTED = 'match_accepted',
  MATCH_DECLINED = 'match_declined',
  MATCH_CANCELLED = 'match_cancelled',
  MATCH_TIMED_OUT = 'match_timed_out',
}

// Matchmaking queue entry type
export interface QueueEntry {
  id: string;
  userId: string;
  displayName: string;
  rating: number;
  timeControl: number;
  increment: number;
  joinedAt: number;
}

// Match type
export interface Match {
  id: string;
  players: {
    red: {
      id: string;
      name: string;
      rating: number;
    };
    black: {
      id: string;
      name: string;
      rating: number;
    };
  };
  timeControl: number;
  increment: number;
  createdAt: number;
  acceptedBy: string[];
  status: 'pending' | 'accepted' | 'declined' | 'cancelled' | 'timed_out';
  gameId?: string;
}

/**
 * Matchmaking service class
 */
class MatchmakingService {
  private eventEmitter: EventEmitter;
  private queueUnsubscribe: (() => void) | null = null;
  private matchUnsubscribe: (() => void) | null = null;
  private currentUserId: string | null = null;
  private queueEntryId: string | null = null;
  private currentMatchId: string | null = null;
  private matchAcceptTimeout: NodeJS.Timeout | null = null;
  
  /**
   * Constructor
   */
  constructor() {
    this.eventEmitter = new EventEmitter();
  }
  
  /**
   * Join the matchmaking queue
   * @param userId User ID
   * @param displayName User display name
   * @param rating User rating
   * @param timeControl Time control in seconds
   * @param increment Increment in seconds
   */
  async joinQueue(
    userId: string,
    displayName: string,
    rating: number,
    timeControl: number = 600,
    increment: number = 10
  ): Promise<void> {
    try {
      this.currentUserId = userId;
      
      // Check if user is already in queue
      const existingEntry = await firestore()
        .collection('matchmaking')
        .where('userId', '==', userId)
        .get();
      
      if (!existingEntry.empty) {
        // User is already in queue, update entry
        this.queueEntryId = existingEntry.docs[0].id;
        
        await firestore()
          .collection('matchmaking')
          .doc(this.queueEntryId)
          .update({
            displayName,
            rating,
            timeControl,
            increment,
            joinedAt: firestore.FieldValue.serverTimestamp(),
          });
      } else {
        // Create new queue entry
        const docRef = await firestore()
          .collection('matchmaking')
          .add({
            userId,
            displayName,
            rating,
            timeControl,
            increment,
            joinedAt: firestore.FieldValue.serverTimestamp(),
          });
        
        this.queueEntryId = docRef.id;
      }
      
      // Listen for matches
      this.listenForMatches();
      
      // Emit queue joined event
      this.eventEmitter.emit(MatchmakingEvent.QUEUE_JOINED, {
        userId,
        displayName,
        rating,
        timeControl,
        increment,
      });
    } catch (error) {
      console.error('Error joining queue:', error);
      store.dispatch(setError('Failed to join matchmaking queue'));
    }
  }
  
  /**
   * Leave the matchmaking queue
   */
  async leaveQueue(): Promise<void> {
    try {
      if (this.queueEntryId) {
        // Remove queue entry
        await firestore()
          .collection('matchmaking')
          .doc(this.queueEntryId)
          .delete();
        
        this.queueEntryId = null;
      }
      
      // Unsubscribe from queue
      if (this.queueUnsubscribe) {
        this.queueUnsubscribe();
        this.queueUnsubscribe = null;
      }
      
      // Emit queue left event
      this.eventEmitter.emit(MatchmakingEvent.QUEUE_LEFT);
    } catch (error) {
      console.error('Error leaving queue:', error);
      store.dispatch(setError('Failed to leave matchmaking queue'));
    }
  }
  
  /**
   * Accept a match
   * @param matchId Match ID
   */
  async acceptMatch(matchId: string): Promise<void> {
    try {
      if (!this.currentUserId) {
        console.error('No current user ID');
        return;
      }
      
      // Update match
      await firestore()
        .collection('matches')
        .doc(matchId)
        .update({
          acceptedBy: firestore.FieldValue.arrayUnion(this.currentUserId),
        });
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Emit match accepted event
      this.eventEmitter.emit(MatchmakingEvent.MATCH_ACCEPTED, { matchId });
    } catch (error) {
      console.error('Error accepting match:', error);
      store.dispatch(setError('Failed to accept match'));
    }
  }
  
  /**
   * Decline a match
   * @param matchId Match ID
   */
  async declineMatch(matchId: string): Promise<void> {
    try {
      // Update match
      await firestore()
        .collection('matches')
        .doc(matchId)
        .update({
          status: 'declined',
        });
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Emit match declined event
      this.eventEmitter.emit(MatchmakingEvent.MATCH_DECLINED, { matchId });
    } catch (error) {
      console.error('Error declining match:', error);
      store.dispatch(setError('Failed to decline match'));
    }
  }
  
  /**
   * Cancel a match
   * @param matchId Match ID
   */
  async cancelMatch(matchId: string): Promise<void> {
    try {
      // Update match
      await firestore()
        .collection('matches')
        .doc(matchId)
        .update({
          status: 'cancelled',
        });
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Emit match cancelled event
      this.eventEmitter.emit(MatchmakingEvent.MATCH_CANCELLED, { matchId });
    } catch (error) {
      console.error('Error cancelling match:', error);
      store.dispatch(setError('Failed to cancel match'));
    }
  }
  
  /**
   * Get active matches for a user
   * @param userId User ID
   * @returns Promise with array of matches
   */
  async getActiveMatches(userId: string): Promise<Match[]> {
    try {
      // Get matches where user is a player and status is 'pending'
      const snapshot = await firestore()
        .collection('matches')
        .where('status', '==', 'pending')
        .where(`players.red.id`, '==', userId)
        .get();
      
      const snapshot2 = await firestore()
        .collection('matches')
        .where('status', '==', 'pending')
        .where(`players.black.id`, '==', userId)
        .get();
      
      // Combine results
      const matches = [
        ...snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })),
        ...snapshot2.docs.map(doc => ({ id: doc.id, ...doc.data() })),
      ] as Match[];
      
      return matches;
    } catch (error) {
      console.error('Error getting active matches:', error);
      store.dispatch(setError('Failed to get active matches'));
      return [];
    }
  }
  
  /**
   * Add an event listener
   * @param event Event type
   * @param listener Event listener
   */
  on(event: MatchmakingEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.on(event, listener);
  }
  
  /**
   * Remove an event listener
   * @param event Event type
   * @param listener Event listener
   */
  off(event: MatchmakingEvent, listener: (...args: any[]) => void): void {
    this.eventEmitter.off(event, listener);
  }
  
  /**
   * Listen for matches
   */
  private listenForMatches(): void {
    if (!this.currentUserId) {
      console.error('No current user ID');
      return;
    }
    
    // Unsubscribe from previous listener
    if (this.matchUnsubscribe) {
      this.matchUnsubscribe();
    }
    
    // Listen for matches where user is a player
    this.matchUnsubscribe = firestore()
      .collection('matches')
      .where(`players.red.id`, '==', this.currentUserId)
      .onSnapshot(snapshot => {
        snapshot.docChanges().forEach(change => {
          if (change.type === 'added') {
            const match = { id: change.doc.id, ...change.doc.data() } as Match;
            this.handleMatchAdded(match);
          } else if (change.type === 'modified') {
            const match = { id: change.doc.id, ...change.doc.data() } as Match;
            this.handleMatchModified(match);
          }
        });
      });
    
    // Also listen for matches where user is black player
    const blackPlayerUnsubscribe = firestore()
      .collection('matches')
      .where(`players.black.id`, '==', this.currentUserId)
      .onSnapshot(snapshot => {
        snapshot.docChanges().forEach(change => {
          if (change.type === 'added') {
            const match = { id: change.doc.id, ...change.doc.data() } as Match;
            this.handleMatchAdded(match);
          } else if (change.type === 'modified') {
            const match = { id: change.doc.id, ...change.doc.data() } as Match;
            this.handleMatchModified(match);
          }
        });
      });
    
    // Combine unsubscribe functions
    this.matchUnsubscribe = () => {
      this.matchUnsubscribe && this.matchUnsubscribe();
      blackPlayerUnsubscribe && blackPlayerUnsubscribe();
    };
  }
  
  /**
   * Handle match added event
   * @param match Match
   */
  private handleMatchAdded(match: Match): void {
    console.log('Match added:', match);
    
    // Set current match ID
    this.currentMatchId = match.id;
    
    // Set match accept timeout
    this.matchAcceptTimeout = setTimeout(() => {
      this.handleMatchTimeout(match.id);
    }, 30000); // 30 seconds to accept
    
    // Emit match found event
    this.eventEmitter.emit(MatchmakingEvent.MATCH_FOUND, match);
  }
  
  /**
   * Handle match modified event
   * @param match Match
   */
  private handleMatchModified(match: Match): void {
    console.log('Match modified:', match);
    
    if (match.status === 'accepted') {
      // Both players accepted, create game
      if (match.acceptedBy.length === 2) {
        this.createGame(match);
      }
    } else if (match.status === 'declined') {
      // Match declined
      this.eventEmitter.emit(MatchmakingEvent.MATCH_DECLINED, match);
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Clear current match ID
      this.currentMatchId = null;
    } else if (match.status === 'cancelled') {
      // Match cancelled
      this.eventEmitter.emit(MatchmakingEvent.MATCH_CANCELLED, match);
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Clear current match ID
      this.currentMatchId = null;
    } else if (match.status === 'timed_out') {
      // Match timed out
      this.eventEmitter.emit(MatchmakingEvent.MATCH_TIMED_OUT, match);
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Clear current match ID
      this.currentMatchId = null;
    }
  }
  
  /**
   * Handle match timeout
   * @param matchId Match ID
   */
  private async handleMatchTimeout(matchId: string): Promise<void> {
    try {
      // Update match
      await firestore()
        .collection('matches')
        .doc(matchId)
        .update({
          status: 'timed_out',
        });
      
      // Emit match timed out event
      this.eventEmitter.emit(MatchmakingEvent.MATCH_TIMED_OUT, { matchId });
      
      // Clear current match ID
      this.currentMatchId = null;
    } catch (error) {
      console.error('Error handling match timeout:', error);
    }
  }
  
  /**
   * Create a game from a match
   * @param match Match
   */
  private async createGame(match: Match): Promise<void> {
    try {
      // Create game
      const gameRef = await firestore().collection('games').add({
        createdAt: firestore.FieldValue.serverTimestamp(),
        createdBy: this.currentUserId,
        status: 'active',
        players: match.players,
        currentFen: 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1',
        moves: [],
        timeControl: {
          initial: match.timeControl,
          increment: match.increment,
        },
        chat: [],
      });
      
      // Update match with game ID
      await firestore()
        .collection('matches')
        .doc(match.id)
        .update({
          gameId: gameRef.id,
        });
      
      // Join the game
      GameSyncService.joinGame(gameRef.id);
      
      // Clear match accept timeout
      if (this.matchAcceptTimeout) {
        clearTimeout(this.matchAcceptTimeout);
        this.matchAcceptTimeout = null;
      }
      
      // Clear current match ID
      this.currentMatchId = null;
    } catch (error) {
      console.error('Error creating game:', error);
      store.dispatch(setError('Failed to create game'));
    }
  }
}

// Export a singleton instance
export default new MatchmakingService();
