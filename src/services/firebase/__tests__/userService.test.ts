import { userService } from '../services';
import firestore from '@react-native-firebase/firestore';
import storage from '@react-native-firebase/storage';

// Mock Firestore
jest.mock('@react-native-firebase/firestore', () => {
  const mockFirestore = {
    collection: jest.fn(() => ({
      doc: jest.fn(() => ({
        get: jest.fn(),
        set: jest.fn(),
        update: jest.fn(),
      })),
      where: jest.fn(() => ({
        get: jest.fn(),
      })),
    })),
  };
  
  return () => mockFirestore;
});

// Mock Storage
jest.mock('@react-native-firebase/storage', () => {
  const mockStorage = {
    ref: jest.fn(() => ({
      putFile: jest.fn(),
      getDownloadURL: jest.fn(),
    })),
  };
  
  return () => mockStorage;
});

describe('User Service', () => {
  // Reset mocks before each test
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  // Test getUserProfile
  describe('getUserProfile', () => {
    it('should get a user profile by ID', async () => {
      // Mock user data from Firestore
      const mockUserData = {
        id: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      };
      
      (firestore().collection().doc().get as jest.Mock).mockResolvedValue({
        exists: true,
        id: 'test-uid',
        data: () => mockUserData,
      });
      
      // Call the get user profile method
      const result = await userService.getUserProfile('test-uid');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
      
      // Check the result
      expect(result).toEqual(mockUserData);
    });
    
    it('should return null for non-existent user', async () => {
      // Mock non-existent user
      (firestore().collection().doc().get as jest.Mock).mockResolvedValue({
        exists: false,
      });
      
      // Call the get user profile method
      const result = await userService.getUserProfile('nonexistent-uid');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('nonexistent-uid');
      
      // Check the result
      expect(result).toBeNull();
    });
    
    it('should handle errors', async () => {
      // Mock an error
      const error = new Error('Firestore error');
      (firestore().collection().doc().get as jest.Mock).mockRejectedValue(error);
      
      // Call the get user profile method and expect it to throw
      await expect(userService.getUserProfile('test-uid')).rejects.toThrow('Firestore error');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
    });
  });
  
  // Test updateUserProfile
  describe('updateUserProfile', () => {
    it('should update a user profile', async () => {
      // Mock successful update
      (firestore().collection().doc().update as jest.Mock).mockResolvedValue(undefined);
      
      // Call the update user profile method
      await userService.updateUserProfile('test-uid', {
        displayName: 'Updated Name',
        photoURL: 'https://example.com/new-photo.jpg',
      });
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
      expect(firestore().collection().doc().update).toHaveBeenCalledWith({
        displayName: 'Updated Name',
        photoURL: 'https://example.com/new-photo.jpg',
      });
    });
    
    it('should handle errors', async () => {
      // Mock an error
      const error = new Error('Firestore error');
      (firestore().collection().doc().update as jest.Mock).mockRejectedValue(error);
      
      // Call the update user profile method and expect it to throw
      await expect(userService.updateUserProfile('test-uid', {
        displayName: 'Updated Name',
      })).rejects.toThrow('Firestore error');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
    });
  });
  
  // Test uploadProfileImage
  describe('uploadProfileImage', () => {
    it('should upload a profile image and update the user profile', async () => {
      // Mock successful upload
      (storage().ref().putFile as jest.Mock).mockResolvedValue({ metadata: { fullPath: 'users/test-uid/profile.jpg' } });
      
      // Mock successful get download URL
      (storage().ref().getDownloadURL as jest.Mock).mockResolvedValue('https://example.com/new-photo.jpg');
      
      // Mock successful update
      (firestore().collection().doc().update as jest.Mock).mockResolvedValue(undefined);
      
      // Call the upload profile image method
      const result = await userService.uploadProfileImage('test-uid', '/path/to/image.jpg');
      
      // Check that Storage was called correctly
      expect(storage().ref).toHaveBeenCalledWith('users/test-uid/profile.jpg');
      expect(storage().ref().putFile).toHaveBeenCalledWith('/path/to/image.jpg');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      expect(firestore().collection().doc).toHaveBeenCalledWith('test-uid');
      expect(firestore().collection().doc().update).toHaveBeenCalledWith({
        photoURL: 'https://example.com/new-photo.jpg',
      });
      
      // Check the result
      expect(result).toBe('https://example.com/new-photo.jpg');
    });
    
    it('should handle upload errors', async () => {
      // Mock an upload error
      const error = new Error('Storage error');
      (storage().ref().putFile as jest.Mock).mockRejectedValue(error);
      
      // Call the upload profile image method and expect it to throw
      await expect(userService.uploadProfileImage('test-uid', '/path/to/image.jpg')).rejects.toThrow('Storage error');
      
      // Check that Storage was called correctly
      expect(storage().ref).toHaveBeenCalledWith('users/test-uid/profile.jpg');
      expect(storage().ref().putFile).toHaveBeenCalledWith('/path/to/image.jpg');
    });
  });
  
  // Test searchUsers
  describe('searchUsers', () => {
    it('should search for users by display name', async () => {
      // Mock search results
      const mockUsers = [
        {
          id: 'user1',
          displayName: 'Test User 1',
          email: 'user1@example.com',
        },
        {
          id: 'user2',
          displayName: 'Test User 2',
          email: 'user2@example.com',
        },
      ];
      
      (firestore().collection().where().get as jest.Mock).mockResolvedValue({
        docs: mockUsers.map(user => ({
          id: user.id,
          data: () => user,
        })),
      });
      
      // Call the search users method
      const result = await userService.searchUsers('Test');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
      
      // Check the result
      expect(result).toEqual(mockUsers.map(user => ({
        id: user.id,
        ...user,
      })));
    });
    
    it('should handle search errors', async () => {
      // Mock an error
      const error = new Error('Firestore error');
      (firestore().collection().where().get as jest.Mock).mockRejectedValue(error);
      
      // Call the search users method and expect it to throw
      await expect(userService.searchUsers('Test')).rejects.toThrow('Firestore error');
      
      // Check that Firestore was called correctly
      expect(firestore().collection).toHaveBeenCalledWith('users');
    });
  });
});
