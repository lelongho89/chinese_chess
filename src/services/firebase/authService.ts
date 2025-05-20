/**
 * Authentication service for the Chinese Chess application
 */
import { auth, firestore } from './index';
import { collections } from './config';
import { User } from '../../store/slices/authSlice';

/**
 * Authentication service class
 */
class AuthService {
  /**
   * Get the current user
   */
  getCurrentUser() {
    return auth().currentUser;
  }

  /**
   * Sign in with email and password
   */
  async signInWithEmailAndPassword(email: string, password: string): Promise<User> {
    try {
      const userCredential = await auth().signInWithEmailAndPassword(email, password);
      
      // Update last login timestamp
      await firestore()
        .collection(collections.USERS)
        .doc(userCredential.user.uid)
        .update({
          lastLoginAt: firestore.FieldValue.serverTimestamp(),
        });
      
      // Get user data from Firestore
      const userDoc = await firestore()
        .collection(collections.USERS)
        .doc(userCredential.user.uid)
        .get();
      
      if (!userDoc.exists) {
        throw new Error('User data not found');
      }
      
      const userData = userDoc.data() as Omit<User, 'id'>;
      
      return {
        id: userCredential.user.uid,
        ...userData,
      } as User;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Sign up with email and password
   */
  async createUserWithEmailAndPassword(
    email: string, 
    password: string, 
    displayName: string
  ): Promise<User> {
    try {
      const userCredential = await auth().createUserWithEmailAndPassword(email, password);
      
      // Update the user's profile
      await userCredential.user.updateProfile({
        displayName,
      });
      
      // Create a user document in Firestore
      const userData = {
        email,
        displayName,
        eloRating: 1200,
        gamesPlayed: 0,
        gamesWon: 0,
        gamesLost: 0,
        gamesDraw: 0,
        createdAt: firestore.FieldValue.serverTimestamp(),
        lastLoginAt: firestore.FieldValue.serverTimestamp(),
      };
      
      await firestore()
        .collection(collections.USERS)
        .doc(userCredential.user.uid)
        .set(userData);
      
      return {
        id: userCredential.user.uid,
        ...userData,
      } as User;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Sign out
   */
  async signOut(): Promise<void> {
    try {
      await auth().signOut();
    } catch (error) {
      throw error;
    }
  }

  /**
   * Reset password
   */
  async resetPassword(email: string): Promise<void> {
    try {
      await auth().sendPasswordResetEmail(email);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(displayName?: string, photoURL?: string): Promise<void> {
    try {
      const user = auth().currentUser;
      if (user) {
        await user.updateProfile({
          displayName: displayName || user.displayName,
          photoURL: photoURL || user.photoURL,
        });
        
        // Update Firestore user document
        if (displayName) {
          await firestore()
            .collection(collections.USERS)
            .doc(user.uid)
            .update({
              displayName,
            });
        }
      }
    } catch (error) {
      throw error;
    }
  }

  /**
   * Listen for auth state changes
   */
  onAuthStateChanged(callback: (user: User | null) => void) {
    return auth().onAuthStateChanged(async (firebaseUser) => {
      if (firebaseUser) {
        // Get user data from Firestore
        try {
          const userDoc = await firestore()
            .collection(collections.USERS)
            .doc(firebaseUser.uid)
            .get();
          
          if (userDoc.exists) {
            const userData = userDoc.data() as Omit<User, 'id'>;
            callback({
              id: firebaseUser.uid,
              ...userData,
            } as User);
          } else {
            callback(null);
          }
        } catch (error) {
          console.error('Error fetching user data:', error);
          callback(null);
        }
      } else {
        callback(null);
      }
    });
  }
}

export default new AuthService();
