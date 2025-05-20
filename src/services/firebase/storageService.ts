/**
 * Storage service for the Chinese Chess application
 */
import { storage } from './index';

/**
 * Storage service class
 */
class StorageService {
  /**
   * Upload a file
   */
  async uploadFile(path: string, file: string, metadata: any = {}): Promise<string> {
    try {
      const reference = storage().ref(path);
      await reference.putFile(file, metadata);
      return await reference.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  /**
   * Download a file URL
   */
  async getFileUrl(path: string): Promise<string> {
    try {
      const reference = storage().ref(path);
      return await reference.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete a file
   */
  async deleteFile(path: string): Promise<void> {
    try {
      const reference = storage().ref(path);
      await reference.delete();
    } catch (error) {
      throw error;
    }
  }

  /**
   * Upload a profile image
   */
  async uploadProfileImage(userId: string, file: string): Promise<string> {
    const path = `users/${userId}/profile.jpg`;
    return this.uploadFile(path, file, {
      contentType: 'image/jpeg',
    });
  }

  /**
   * Get a profile image URL
   */
  async getProfileImageUrl(userId: string): Promise<string> {
    const path = `users/${userId}/profile.jpg`;
    return this.getFileUrl(path);
  }
}

export default new StorageService();
