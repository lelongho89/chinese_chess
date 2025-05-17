import { 
  validateEmail, 
  validatePassword, 
  validateUsername, 
  validatePhoneNumber 
} from '../validators';

describe('Validators', () => {
  // Test validateEmail
  describe('validateEmail', () => {
    it('should validate correct email formats', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('test.name@example.co.uk')).toBe(true);
      expect(validateEmail('test+label@example.com')).toBe(true);
      expect(validateEmail('test123@example.com')).toBe(true);
    });
    
    it('should reject incorrect email formats', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('test@example')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
      expect(validateEmail('test@.com')).toBe(false);
      expect(validateEmail('test@example.')).toBe(false);
      expect(validateEmail('test@exam ple.com')).toBe(false);
    });
    
    it('should handle null and undefined', () => {
      expect(validateEmail(null)).toBe(false);
      expect(validateEmail(undefined)).toBe(false);
    });
  });
  
  // Test validatePassword
  describe('validatePassword', () => {
    it('should validate passwords that meet requirements', () => {
      // Assuming requirements: at least 8 chars, 1 uppercase, 1 lowercase, 1 number
      expect(validatePassword('Password123')).toBe(true);
      expect(validatePassword('Abcdef1!')).toBe(true);
      expect(validatePassword('1234Abcd')).toBe(true);
      expect(validatePassword('P@ssw0rd')).toBe(true);
    });
    
    it('should reject passwords that do not meet requirements', () => {
      expect(validatePassword('')).toBe(false);
      expect(validatePassword('pass')).toBe(false); // Too short
      expect(validatePassword('password')).toBe(false); // No uppercase or number
      expect(validatePassword('PASSWORD123')).toBe(false); // No lowercase
      expect(validatePassword('Password')).toBe(false); // No number
      expect(validatePassword('12345678')).toBe(false); // No letters
    });
    
    it('should handle null and undefined', () => {
      expect(validatePassword(null)).toBe(false);
      expect(validatePassword(undefined)).toBe(false);
    });
  });
  
  // Test validateUsername
  describe('validateUsername', () => {
    it('should validate usernames that meet requirements', () => {
      // Assuming requirements: 3-20 chars, alphanumeric and underscores
      expect(validateUsername('user123')).toBe(true);
      expect(validateUsername('user_name')).toBe(true);
      expect(validateUsername('User')).toBe(true);
      expect(validateUsername('u123')).toBe(true);
      expect(validateUsername('username_123_long')).toBe(true);
    });
    
    it('should reject usernames that do not meet requirements', () => {
      expect(validateUsername('')).toBe(false);
      expect(validateUsername('ab')).toBe(false); // Too short
      expect(validateUsername('username_that_is_way_too_long')).toBe(false); // Too long
      expect(validateUsername('user name')).toBe(false); // Contains space
      expect(validateUsername('user@name')).toBe(false); // Contains special char
      expect(validateUsername('user-name')).toBe(false); // Contains hyphen
    });
    
    it('should handle null and undefined', () => {
      expect(validateUsername(null)).toBe(false);
      expect(validateUsername(undefined)).toBe(false);
    });
  });
  
  // Test validatePhoneNumber
  describe('validatePhoneNumber', () => {
    it('should validate correct phone number formats', () => {
      expect(validatePhoneNumber('1234567890')).toBe(true);
      expect(validatePhoneNumber('123-456-7890')).toBe(true);
      expect(validatePhoneNumber('(123) 456-7890')).toBe(true);
      expect(validatePhoneNumber('+1 123-456-7890')).toBe(true);
    });
    
    it('should reject incorrect phone number formats', () => {
      expect(validatePhoneNumber('')).toBe(false);
      expect(validatePhoneNumber('123')).toBe(false); // Too short
      expect(validatePhoneNumber('abcdefghij')).toBe(false); // Not a number
      expect(validatePhoneNumber('123456789012345')).toBe(false); // Too long
      expect(validatePhoneNumber('123 abc 7890')).toBe(false); // Contains letters
    });
    
    it('should handle null and undefined', () => {
      expect(validatePhoneNumber(null)).toBe(false);
      expect(validatePhoneNumber(undefined)).toBe(false);
    });
  });
});
