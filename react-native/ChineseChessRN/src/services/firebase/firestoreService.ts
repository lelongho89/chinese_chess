/**
 * Firestore service for the Chinese Chess application
 */
import { firestore } from './index';
import { collections } from './config';
import { User } from '../../store/slices/authSlice';

/**
 * Game data type
 */
export type GameData = {
  id?: string;
  players: string[];
  playerData: {
    [userId: string]: {
      color: 'red' | 'black';
      rating: number;
    };
  };
  status: 'active' | 'completed' | 'abandoned';
  winner?: string;
  startPosition: string;
  currentPosition: string;
  moves: {
    from: { row: number; col: number };
    to: { row: number; col: number };
    piece: string;
    capturedPiece?: string;
    timestamp: any;
  }[];
  gameMode: 'ranked' | 'friendly' | 'tournament';
  timeControl: {
    initialTime: number;
    increment: number;
  };
  createdAt: any;
  updatedAt: any;
  completedAt?: any;
};

/**
 * User settings type
 */
export type UserSettings = {
  language: 'english' | 'chinese' | 'vietnamese';
  skin: string;
  soundEnabled: boolean;
  notificationsEnabled: boolean;
  updatedAt: any;
};

/**
 * Firestore service class
 */
class FirestoreService {
  /**
   * Get a user by ID
   */
  async getUser(userId: string): Promise<User | null> {
    try {
      const doc = await firestore().collection(collections.USERS).doc(userId).get();
      if (doc.exists) {
        return { id: doc.id, ...doc.data() } as User;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update a user's data
   */
  async updateUser(userId: string, data: Partial<User>): Promise<void> {
    try {
      await firestore()
        .collection(collections.USERS)
        .doc(userId)
        .update({
          ...data,
          updatedAt: firestore.FieldValue.serverTimestamp(),
        });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Create a new game
   */
  async createGame(gameData: Omit<GameData, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    try {
      const gameRef = await firestore()
        .collection(collections.GAMES)
        .add({
          ...gameData,
          createdAt: firestore.FieldValue.serverTimestamp(),
          updatedAt: firestore.FieldValue.serverTimestamp(),
        });
      return gameRef.id;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get a game by ID
   */
  async getGame(gameId: string): Promise<GameData | null> {
    try {
      const doc = await firestore().collection(collections.GAMES).doc(gameId).get();
      if (doc.exists) {
        return { id: doc.id, ...doc.data() } as GameData;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update a game
   */
  async updateGame(gameId: string, data: Partial<GameData>): Promise<void> {
    try {
      await firestore()
        .collection(collections.GAMES)
        .doc(gameId)
        .update({
          ...data,
          updatedAt: firestore.FieldValue.serverTimestamp(),
        });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Listen for game changes
   */
  onGameChanged(gameId: string, callback: (game: GameData) => void) {
    return firestore()
      .collection(collections.GAMES)
      .doc(gameId)
      .onSnapshot((doc) => {
        if (doc.exists) {
          callback({ id: doc.id, ...doc.data() } as GameData);
        }
      });
  }

  /**
   * Get user's games
   */
  async getUserGames(userId: string, limit = 10): Promise<GameData[]> {
    try {
      const snapshot = await firestore()
        .collection(collections.GAMES)
        .where('players', 'array-contains', userId)
        .orderBy('createdAt', 'desc')
        .limit(limit)
        .get();
      
      return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() } as GameData));
    } catch (error) {
      throw error;
    }
  }

  /**
   * Create or update user settings
   */
  async updateUserSettings(userId: string, settings: Partial<UserSettings>): Promise<void> {
    try {
      await firestore()
        .collection(collections.USER_SETTINGS)
        .doc(userId)
        .set(
          { 
            ...settings, 
            updatedAt: firestore.FieldValue.serverTimestamp() 
          },
          { merge: true }
        );
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user settings
   */
  async getUserSettings(userId: string): Promise<UserSettings | null> {
    try {
      const doc = await firestore()
        .collection(collections.USER_SETTINGS)
        .doc(userId)
        .get();
      
      if (doc.exists) {
        return doc.data() as UserSettings;
      }
      return null;
    } catch (error) {
      throw error;
    }
  }
}

export default new FirestoreService();
