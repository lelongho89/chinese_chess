import { authService } from '../services';
import auth from '@react-native-firebase/auth';
import firestore from '@react-native-firebase/firestore';

// Mock Firebase Auth
jest.mock('@react-native-firebase/auth', () => {
  const mockAuth = {
    signInWithEmailAndPassword: jest.fn(),
    createUserWithEmailAndPassword: jest.fn(),
    signOut: jest.fn(),
    sendPasswordResetEmail: jest.fn(),
    currentUser: {
      updateProfile: jest.fn(),
      updateEmail: jest.fn(),
      updatePassword: jest.fn(),
      reauthenticateWithCredential: jest.fn(),
      delete: jest.fn(),
    },
    EmailAuthProvider: {
      credential: jest.fn(),
    },
  };
  
  return () => mockAuth;
});

// Mock Firestore
jest.mock('@react-native-firebase/firestore', () => {
  const mockFirestore = {
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        set: jest.fn(),
        update: jest.fn(),
        get: jest.fn(),
      })),
    })),
  };
  
  return () => mockFirestore;
});

describe('Auth Service', () => {
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  // Test signIn
  describe('signIn', () => {
    it('should sign in a user with email and password', async () => {
      // Mock successful sign in
      const mockUser = { uid: 'test-uid', email: 'test@example.com' };
      (auth().signInWithEmailAndPassword as jest.Mock).mockResolvedValue({ user: mockUser });
      
      // Mock user data from Firestore
      const mockUserData = { displayName: 'Test User', photoURL: 'https://example.com/photo.jpg' };
      (firestore().collection().doc().get as jest.Mock).mockResolvedValue({
        exists: true,
        data: () => mockUserData,
      });
      
      // Call the sign in method
      const result = await authService.signIn('test@example.com', 'password123');
      
      // Check that Firebase Auth was called correctly
      expect(auth().signInWithEmailAndPassword).toHaveBeenCalledWith('test@example.com', 'password123');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
      
      // Check the result
      expect(result).toEqual({
        id: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      });
    });
    
    it('should handle sign in errors', async () => {
      // Mock a failed sign in
      const error = new Error('Invalid credentials');
      (auth().signInWithEmailAndPassword as jest.Mock).mockRejectedValue(error);
      
      // Call the sign in method and expect it to throw
      await expect(authService.signIn('test@example.com', 'wrong-password')).rejects.toThrow('Invalid credentials');
      
      // Check that Firebase Auth was called correctly
      expect(auth().signInWithEmailAndPassword).toHaveBeenCalledWith('test@example.com', 'wrong-password');
    });
  });
  
  // Test signUp
  describe('signUp', () => {
    it('should sign up a new user', async () => {
      // Mock successful sign up
      const mockUser = { uid: 'test-uid', email: 'test@example.com' };
      (auth().createUserWithEmailAndPassword as jest.Mock).mockResolvedValue({ user: mockUser });
      
      // Mock update profile
      (auth().currentUser.updateProfile as jest.Mock).mockResolvedValue(undefined);
      
      // Mock Firestore set
      (firestore().collection().doc().set as jest.Mock).mockResolvedValue(undefined);
      
      // Call the sign up method
      const result = await authService.signUp('test@example.com', 'password123', 'Test User');
      
      // Check that Firebase Auth was called correctly
      expect(auth().createUserWithEmailAndPassword).toHaveBeenCalledWith('test@example.com', 'password123');
      expect(auth().currentUser.updateProfile).toHaveBeenCalledWith({ displayName: 'Test User' });
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
      expect(firestore().collection().doc().set).toHaveBeenCalledWith({
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: expect.any(Object),
      });
      
      // Check the result
      expect(result).toEqual({
        id: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: null,
      });
    });
    
    it('should handle sign up errors', async () => {
      // Mock a failed sign up
      const error = new Error('Email already in use');
      (auth().createUserWithEmailAndPassword as jest.Mock).mockRejectedValue(error);
      
      // Call the sign up method and expect it to throw
      await expect(authService.signUp('existing@example.com', 'password123', 'Test User')).rejects.toThrow('Email already in use');
      
      // Check that Firebase Auth was called correctly
      expect(auth().createUserWithEmailAndPassword).toHaveBeenCalledWith('existing@example.com', 'password123');
    });
  });
  
  // Test signOut
  describe('signOut', () => {
    it('should sign out the current user', async () => {
      // Mock successful sign out
      (auth().signOut as jest.Mock).mockResolvedValue(undefined);
      
      // Call the sign out method
      await authService.signOut();
      
      // Check that Firebase Auth was called correctly
      expect(auth().signOut).toHaveBeenCalled();
    });
    
    it('should handle sign out errors', async () => {
      // Mock a failed sign out
      const error = new Error('Sign out failed');
      (auth().signOut as jest.Mock).mockRejectedValue(error);
      
      // Call the sign out method and expect it to throw
      await expect(authService.signOut()).rejects.toThrow('Sign out failed');
      
      // Check that Firebase Auth was called correctly
      expect(auth().signOut).toHaveBeenCalled();
    });
  });
  
  // Test resetPassword
  describe('resetPassword', () => {
    it('should send a password reset email', async () => {
      // Mock successful password reset
      (auth().sendPasswordResetEmail as jest.Mock).mockResolvedValue(undefined);
      
      // Call the reset password method
      await authService.resetPassword('test@example.com');
      
      // Check that Firebase Auth was called correctly
      expect(auth().sendPasswordResetEmail).toHaveBeenCalledWith('test@example.com');
    });
    
    it('should handle password reset errors', async () => {
      // Mock a failed password reset
      const error = new Error('User not found');
      (auth().sendPasswordResetEmail as jest.Mock).mockRejectedValue(error);
      
      // Call the reset password method and expect it to throw
      await expect(authService.resetPassword('nonexistent@example.com')).rejects.toThrow('User not found');
      
      // Check that Firebase Auth was called correctly
      expect(auth().sendPasswordResetEmail).toHaveBeenCalledWith('nonexistent@example.com');
    });
  });
});
