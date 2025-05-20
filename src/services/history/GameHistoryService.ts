/**
 * Game history service for the Chinese Chess application
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import firestore from '@react-native-firebase/firestore';
import { store } from '../../store';
import { setError, setGameHistory } from '../../store/slices/gameSlice';
import { Move } from '../game/Board';

/**
 * Game history entry type
 */
export interface GameHistoryEntry {
  id: string;
  date: number;
  gameMode: 'ai' | 'online' | 'free';
  result: 'win' | 'loss' | 'draw';
  playerColor: 'red' | 'black';
  opponent: string;
  moves: Move[];
  finalFen: string;
  timeControl?: {
    initial: number;
    increment: number;
  };
  playerRating?: number;
  opponentRating?: number;
  ratingChange?: number;
}

/**
 * Game history service class
 */
class GameHistoryService {
  private readonly STORAGE_KEY = 'game_history';
  private readonly MAX_LOCAL_HISTORY = 50;
  
  /**
   * Save a game to history
   * @param game Game history entry
   * @param userId User ID (optional, for online games)
   */
  async saveGame(game: Omit<GameHistoryEntry, 'id'>, userId?: string): Promise<string> {
    try {
      // Generate a unique ID
      const id = `game_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const gameWithId: GameHistoryEntry = { ...game, id };
      
      // Save to local storage
      await this.saveToLocalStorage(gameWithId);
      
      // If user is logged in, save to Firestore
      if (userId) {
        await this.saveToFirestore(gameWithId, userId);
      }
      
      return id;
    } catch (error) {
      console.error('Error saving game to history:', error);
      store.dispatch(setError('Failed to save game to history'));
      throw error;
    }
  }
  
  /**
   * Get game history from local storage
   * @returns Array of game history entries
   */
  async getLocalHistory(): Promise<GameHistoryEntry[]> {
    try {
      const historyJson = await AsyncStorage.getItem(this.STORAGE_KEY);
      
      if (!historyJson) {
        return [];
      }
      
      return JSON.parse(historyJson) as GameHistoryEntry[];
    } catch (error) {
      console.error('Error getting game history from local storage:', error);
      store.dispatch(setError('Failed to get game history from local storage'));
      return [];
    }
  }
  
  /**
   * Get game history from Firestore
   * @param userId User ID
   * @param limit Number of games to return
   * @returns Array of game history entries
   */
  async getFirestoreHistory(userId: string, limit: number = 20): Promise<GameHistoryEntry[]> {
    try {
      const snapshot = await firestore()
        .collection('users')
        .doc(userId)
        .collection('games')
        .orderBy('date', 'desc')
        .limit(limit)
        .get();
      
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      })) as GameHistoryEntry[];
    } catch (error) {
      console.error('Error getting game history from Firestore:', error);
      store.dispatch(setError('Failed to get game history from Firestore'));
      return [];
    }
  }
  
  /**
   * Get a specific game from history
   * @param gameId Game ID
   * @param userId User ID (optional, for online games)
   * @returns Game history entry or null if not found
   */
  async getGame(gameId: string, userId?: string): Promise<GameHistoryEntry | null> {
    try {
      // Try to get from local storage first
      const localHistory = await this.getLocalHistory();
      const localGame = localHistory.find(game => game.id === gameId);
      
      if (localGame) {
        return localGame;
      }
      
      // If not found locally and user is logged in, try Firestore
      if (userId) {
        const doc = await firestore()
          .collection('users')
          .doc(userId)
          .collection('games')
          .doc(gameId)
          .get();
        
        if (doc.exists) {
          return { id: doc.id, ...doc.data() } as GameHistoryEntry;
        }
      }
      
      return null;
    } catch (error) {
      console.error('Error getting game from history:', error);
      store.dispatch(setError('Failed to get game from history'));
      return null;
    }
  }
  
  /**
   * Delete a game from history
   * @param gameId Game ID
   * @param userId User ID (optional, for online games)
   */
  async deleteGame(gameId: string, userId?: string): Promise<void> {
    try {
      // Delete from local storage
      const localHistory = await this.getLocalHistory();
      const updatedHistory = localHistory.filter(game => game.id !== gameId);
      await AsyncStorage.setItem(this.STORAGE_KEY, JSON.stringify(updatedHistory));
      
      // If user is logged in, delete from Firestore
      if (userId) {
        await firestore()
          .collection('users')
          .doc(userId)
          .collection('games')
          .doc(gameId)
          .delete();
      }
    } catch (error) {
      console.error('Error deleting game from history:', error);
      store.dispatch(setError('Failed to delete game from history'));
      throw error;
    }
  }
  
  /**
   * Clear all game history
   * @param userId User ID (optional, for online games)
   */
  async clearHistory(userId?: string): Promise<void> {
    try {
      // Clear local storage
      await AsyncStorage.removeItem(this.STORAGE_KEY);
      
      // If user is logged in, clear Firestore
      if (userId) {
        // Get all games
        const snapshot = await firestore()
          .collection('users')
          .doc(userId)
          .collection('games')
          .get();
        
        // Delete each game
        const batch = firestore().batch();
        snapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        
        await batch.commit();
      }
    } catch (error) {
      console.error('Error clearing game history:', error);
      store.dispatch(setError('Failed to clear game history'));
      throw error;
    }
  }
  
  /**
   * Export game history as PGN (Portable Game Notation)
   * @param game Game history entry
   * @returns PGN string
   */
  exportAsPGN(game: GameHistoryEntry): string {
    const date = new Date(game.date);
    const dateStr = date.toISOString().split('T')[0];
    
    let pgn = '';
    
    // Add headers
    pgn += `[Event "Chinese Chess Game"]\n`;
    pgn += `[Site "Chinese Chess App"]\n`;
    pgn += `[Date "${dateStr}"]\n`;
    pgn += `[Round "1"]\n`;
    pgn += `[Red "${game.playerColor === 'red' ? 'Player' : game.opponent}"]\n`;
    pgn += `[Black "${game.playerColor === 'black' ? 'Player' : game.opponent}"]\n`;
    pgn += `[Result "${game.result === 'win' ? (game.playerColor === 'red' ? '1-0' : '0-1') : (game.result === 'loss' ? (game.playerColor === 'red' ? '0-1' : '1-0') : '1/2-1/2')}"]\n`;
    pgn += `[FinalFEN "${game.finalFen}"]\n\n`;
    
    // Add moves
    let moveNumber = 1;
    for (let i = 0; i < game.moves.length; i += 2) {
      pgn += `${moveNumber}. `;
      
      // Red's move
      const redMove = game.moves[i];
      pgn += `${this.formatMove(redMove)} `;
      
      // Black's move (if exists)
      if (i + 1 < game.moves.length) {
        const blackMove = game.moves[i + 1];
        pgn += `${this.formatMove(blackMove)} `;
      }
      
      pgn += '\n';
      moveNumber++;
    }
    
    // Add result
    pgn += `${game.result === 'win' ? (game.playerColor === 'red' ? '1-0' : '0-1') : (game.result === 'loss' ? (game.playerColor === 'red' ? '0-1' : '1-0') : '1/2-1/2')}`;
    
    return pgn;
  }
  
  /**
   * Import game history from PGN (Portable Game Notation)
   * @param pgn PGN string
   * @returns Game history entry
   */
  importFromPGN(pgn: string): GameHistoryEntry | null {
    try {
      const lines = pgn.split('\n');
      
      // Parse headers
      const headers: Record<string, string> = {};
      let i = 0;
      
      while (i < lines.length && lines[i].startsWith('[')) {
        const match = lines[i].match(/\[(\w+)\s+"(.*)"\]/);
        if (match) {
          headers[match[1]] = match[2];
        }
        i++;
      }
      
      // Skip empty lines
      while (i < lines.length && lines[i].trim() === '') {
        i++;
      }
      
      // Parse moves
      const moves: Move[] = [];
      
      while (i < lines.length && !lines[i].match(/^(1-0|0-1|1\/2-1\/2|\*)$/)) {
        const moveLine = lines[i].trim();
        
        // Extract moves from the line
        const moveMatches = moveLine.match(/\d+\.\s+([a-zA-Z0-9+#=]+)\s+([a-zA-Z0-9+#=]+)?/);
        
        if (moveMatches) {
          // Parse red's move
          const redMove = this.parseMove(moveMatches[1]);
          if (redMove) {
            moves.push(redMove);
          }
          
          // Parse black's move if it exists
          if (moveMatches[2]) {
            const blackMove = this.parseMove(moveMatches[2]);
            if (blackMove) {
              moves.push(blackMove);
            }
          }
        }
        
        i++;
      }
      
      // Determine result
      let result: 'win' | 'loss' | 'draw';
      let playerColor: 'red' | 'black';
      
      if (headers['Result'] === '1-0') {
        result = headers['Red'] === 'Player' ? 'win' : 'loss';
        playerColor = headers['Red'] === 'Player' ? 'red' : 'black';
      } else if (headers['Result'] === '0-1') {
        result = headers['Black'] === 'Player' ? 'win' : 'loss';
        playerColor = headers['Black'] === 'Player' ? 'red' : 'black';
      } else {
        result = 'draw';
        playerColor = headers['Red'] === 'Player' ? 'red' : 'black';
      }
      
      // Create game history entry
      return {
        id: `imported_${Date.now()}`,
        date: headers['Date'] ? new Date(headers['Date']).getTime() : Date.now(),
        gameMode: 'free',
        result,
        playerColor,
        opponent: playerColor === 'red' ? headers['Black'] : headers['Red'],
        moves,
        finalFen: headers['FinalFEN'] || '',
      };
    } catch (error) {
      console.error('Error importing game from PGN:', error);
      store.dispatch(setError('Failed to import game from PGN'));
      return null;
    }
  }
  
  /**
   * Save a game to local storage
   * @param game Game history entry
   */
  private async saveToLocalStorage(game: GameHistoryEntry): Promise<void> {
    try {
      // Get existing history
      const history = await this.getLocalHistory();
      
      // Add new game
      history.unshift(game);
      
      // Limit the number of games
      const limitedHistory = history.slice(0, this.MAX_LOCAL_HISTORY);
      
      // Save to storage
      await AsyncStorage.setItem(this.STORAGE_KEY, JSON.stringify(limitedHistory));
    } catch (error) {
      console.error('Error saving game to local storage:', error);
      throw error;
    }
  }
  
  /**
   * Save a game to Firestore
   * @param game Game history entry
   * @param userId User ID
   */
  private async saveToFirestore(game: GameHistoryEntry, userId: string): Promise<void> {
    try {
      await firestore()
        .collection('users')
        .doc(userId)
        .collection('games')
        .doc(game.id)
        .set(game);
    } catch (error) {
      console.error('Error saving game to Firestore:', error);
      throw error;
    }
  }
  
  /**
   * Format a move for PGN
   * @param move Move
   * @returns Formatted move string
   */
  private formatMove(move: Move): string {
    const { from, to, piece } = move;
    return `${piece}${from.col}${from.row}-${to.col}${to.row}`;
  }
  
  /**
   * Parse a move from PGN
   * @param moveStr Move string
   * @returns Move object
   */
  private parseMove(moveStr: string): Move | null {
    const match = moveStr.match(/([A-Za-z])(\d)(\d)-(\d)(\d)/);
    
    if (!match) {
      return null;
    }
    
    return {
      piece: match[1],
      from: {
        col: parseInt(match[2]),
        row: parseInt(match[3]),
      },
      to: {
        col: parseInt(match[4]),
        row: parseInt(match[5]),
      },
    };
  }
}

// Export a singleton instance
export default new GameHistoryService();
