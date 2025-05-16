/**
 * Authentication hook for the Chinese Chess application
 */
import { useEffect } from 'react';
import { useAppDispatch, useAppSelector } from './useRedux';
import { setUser, setLoading, setError, logout } from '../store/slices/authSlice';
import { authService, analyticsService } from '../services/firebase/services';

/**
 * Hook for Firebase authentication
 */
export const useAuth = () => {
  const dispatch = useAppDispatch();
  const { user, isLoading, error } = useAppSelector(state => state.auth);

  // Listen for auth state changes
  useEffect(() => {
    dispatch(setLoading(true));
    
    const unsubscribe = authService.onAuthStateChanged((user) => {
      if (user) {
        dispatch(setUser(user));
        analyticsService.setUserId(user.id);
        analyticsService.setUserProperties({
          eloRating: user.eloRating.toString(),
          gamesPlayed: user.gamesPlayed.toString(),
        });
      } else {
        dispatch(logout());
      }
      
      dispatch(setLoading(false));
    });
    
    return () => unsubscribe();
  }, [dispatch]);

  /**
   * Sign in with email and password
   */
  const signIn = async (email: string, password: string) => {
    try {
      dispatch(setLoading(true));
      dispatch(setError(null));
      
      const user = await authService.signInWithEmailAndPassword(email, password);
      dispatch(setUser(user));
      
      analyticsService.logLogin('email');
      
      return user;
    } catch (error: any) {
      dispatch(setError(error.message));
      throw error;
    } finally {
      dispatch(setLoading(false));
    }
  };

  /**
   * Sign up with email and password
   */
  const signUp = async (email: string, password: string, displayName: string) => {
    try {
      dispatch(setLoading(true));
      dispatch(setError(null));
      
      const user = await authService.createUserWithEmailAndPassword(email, password, displayName);
      dispatch(setUser(user));
      
      analyticsService.logSignUp('email');
      
      return user;
    } catch (error: any) {
      dispatch(setError(error.message));
      throw error;
    } finally {
      dispatch(setLoading(false));
    }
  };

  /**
   * Sign out
   */
  const signOut = async () => {
    try {
      dispatch(setLoading(true));
      await authService.signOut();
      dispatch(logout());
    } catch (error: any) {
      dispatch(setError(error.message));
      throw error;
    } finally {
      dispatch(setLoading(false));
    }
  };

  /**
   * Reset password
   */
  const resetPassword = async (email: string) => {
    try {
      dispatch(setLoading(true));
      dispatch(setError(null));
      await authService.resetPassword(email);
    } catch (error: any) {
      dispatch(setError(error.message));
      throw error;
    } finally {
      dispatch(setLoading(false));
    }
  };

  return {
    user,
    isLoading,
    error,
    isAuthenticated: !!user,
    signIn,
    signUp,
    signOut,
    resetPassword,
  };
};
