/**
 * Analytics service for the Chinese Chess application
 */
import { analytics } from './index';

/**
 * Analytics service class
 */
class AnalyticsService {
  /**
   * Log a custom event
   */
  async logEvent(eventName: string, params?: Record<string, any>): Promise<void> {
    try {
      await analytics().logEvent(eventName, params);
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Log screen view
   */
  async logScreenView(screenName: string, screenClass?: string): Promise<void> {
    try {
      await analytics().logScreenView({
        screen_name: screenName,
        screen_class: screenClass || screenName,
      });
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Log game start
   */
  async logGameStart(gameMode: string, gameId?: string): Promise<void> {
    try {
      await this.logEvent('game_start', {
        game_mode: gameMode,
        game_id: gameId,
      });
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Log game end
   */
  async logGameEnd(gameMode: string, result: 'win' | 'loss' | 'draw', duration: number, gameId?: string): Promise<void> {
    try {
      await this.logEvent('game_end', {
        game_mode: gameMode,
        result,
        duration,
        game_id: gameId,
      });
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Log user login
   */
  async logLogin(method: string): Promise<void> {
    try {
      await analytics().logLogin({
        method,
      });
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Log user signup
   */
  async logSignUp(method: string): Promise<void> {
    try {
      await analytics().logSignUp({
        method,
      });
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Set user ID
   */
  async setUserId(userId: string): Promise<void> {
    try {
      await analytics().setUserId(userId);
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  /**
   * Set user properties
   */
  async setUserProperties(properties: Record<string, string>): Promise<void> {
    try {
      for (const [key, value] of Object.entries(properties)) {
        await analytics().setUserProperty(key, value);
      }
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }
}

export default new AnalyticsService();
