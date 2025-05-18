import { 
  formatDate, 
  formatTime, 
  formatDuration, 
  formatScore 
} from '../formatters';

describe('Formatters', () => {
  // Test formatDate
  describe('formatDate', () => {
    it('should format a date correctly', () => {
      // Create a specific date for testing
      const date = new Date(2023, 0, 15); // January 15, 2023
      
      // Format the date
      const formattedDate = formatDate(date);
      
      // Check the format (this will depend on the implementation)
      expect(formattedDate).toMatch(/^\d{1,2}\/\d{1,2}\/\d{4}$/); // MM/DD/YYYY format
      expect(formattedDate).toBe('1/15/2023');
    });
    
    it('should handle different date formats', () => {
      // Test with timestamp
      const timestamp = new Date(2023, 0, 15).getTime();
      expect(formatDate(timestamp)).toBe('1/15/2023');
      
      // Test with ISO string
      const isoString = new Date(2023, 0, 15).toISOString();
      expect(formatDate(isoString)).toBe('1/15/2023');
    });
    
    it('should return "Invalid Date" for invalid inputs', () => {
      expect(formatDate('not a date')).toBe('Invalid Date');
      expect(formatDate(null)).toBe('Invalid Date');
      expect(formatDate(undefined)).toBe('Invalid Date');
    });
  });
  
  // Test formatTime
  describe('formatTime', () => {
    it('should format a time correctly', () => {
      // Create a specific time for testing
      const time = new Date(2023, 0, 15, 14, 30, 45); // 2:30:45 PM
      
      // Format the time
      const formattedTime = formatTime(time);
      
      // Check the format (this will depend on the implementation)
      expect(formattedTime).toMatch(/^\d{1,2}:\d{2}(:\d{2})?\s?(AM|PM)?$/); // HH:MM(:SS) (AM/PM) format
      expect(formattedTime).toBe('2:30 PM');
    });
    
    it('should handle different time formats', () => {
      // Test with timestamp
      const timestamp = new Date(2023, 0, 15, 14, 30, 45).getTime();
      expect(formatTime(timestamp)).toBe('2:30 PM');
      
      // Test with ISO string
      const isoString = new Date(2023, 0, 15, 14, 30, 45).toISOString();
      expect(formatTime(isoString)).toBe('2:30 PM');
    });
    
    it('should return "Invalid Time" for invalid inputs', () => {
      expect(formatTime('not a time')).toBe('Invalid Time');
      expect(formatTime(null)).toBe('Invalid Time');
      expect(formatTime(undefined)).toBe('Invalid Time');
    });
  });
  
  // Test formatDuration
  describe('formatDuration', () => {
    it('should format seconds into minutes and seconds', () => {
      expect(formatDuration(90)).toBe('1:30');
      expect(formatDuration(65)).toBe('1:05');
      expect(formatDuration(3661)).toBe('1:01:01');
    });
    
    it('should handle zero and negative values', () => {
      expect(formatDuration(0)).toBe('0:00');
      expect(formatDuration(-60)).toBe('0:00');
    });
    
    it('should handle large values', () => {
      expect(formatDuration(3600)).toBe('1:00:00');
      expect(formatDuration(7200)).toBe('2:00:00');
      expect(formatDuration(7265)).toBe('2:01:05');
    });
  });
  
  // Test formatScore
  describe('formatScore', () => {
    it('should format scores correctly', () => {
      expect(formatScore(1000)).toBe('1,000');
      expect(formatScore(1500.5)).toBe('1,500.5');
      expect(formatScore(1000000)).toBe('1,000,000');
    });
    
    it('should handle zero and negative values', () => {
      expect(formatScore(0)).toBe('0');
      expect(formatScore(-1000)).toBe('-1,000');
    });
    
    it('should handle decimal places correctly', () => {
      expect(formatScore(1000.123, 2)).toBe('1,000.12');
      expect(formatScore(1000.5, 0)).toBe('1,000');
      expect(formatScore(1000.5, 3)).toBe('1,000.500');
    });
  });
});
