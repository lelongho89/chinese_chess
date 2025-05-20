import authReducer, {
  setUser,
  setLoading,
  setError,
  clearError,
  logout,
  AuthState,
} from '../authSlice';

describe('Auth Slice', () => {
  // Initial state test
  it('should return the initial state', () => {
    const initialState = authReducer(undefined, { type: undefined });
    
    expect(initialState.user).toBeNull();
    expect(initialState.isLoading).toBe(false);
    expect(initialState.error).toBeNull();
  });
  
  // Test setUser action
  it('should handle setUser', () => {
    const user = {
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
    };
    
    const initialState = authReducer(undefined, { type: undefined });
    const nextState = authReducer(initialState, setUser(user));
    
    expect(nextState.user).toEqual(user);
    expect(nextState.isLoading).toBe(false);
    expect(nextState.error).toBeNull();
  });
  
  // Test setLoading action
  it('should handle setLoading', () => {
    const initialState = authReducer(undefined, { type: undefined });
    
    // Set loading to true
    const loadingState = authReducer(initialState, setLoading(true));
    expect(loadingState.isLoading).toBe(true);
    
    // Set loading to false
    const notLoadingState = authReducer(loadingState, setLoading(false));
    expect(notLoadingState.isLoading).toBe(false);
  });
  
  // Test setError action
  it('should handle setError', () => {
    const error = 'Authentication failed';
    
    const initialState = authReducer(undefined, { type: undefined });
    const errorState = authReducer(initialState, setError(error));
    
    expect(errorState.error).toBe(error);
    expect(errorState.isLoading).toBe(false);
  });
  
  // Test clearError action
  it('should handle clearError', () => {
    // Start with an error state
    const errorState: AuthState = {
      user: null,
      isLoading: false,
      error: 'Authentication failed',
    };
    
    const clearedState = authReducer(errorState, clearError());
    
    expect(clearedState.error).toBeNull();
  });
  
  // Test logout action
  it('should handle logout', () => {
    // Start with a logged-in state
    const loggedInState: AuthState = {
      user: {
        id: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      },
      isLoading: false,
      error: null,
    };
    
    const loggedOutState = authReducer(loggedInState, logout());
    
    expect(loggedOutState.user).toBeNull();
    expect(loggedOutState.isLoading).toBe(false);
    expect(loggedOutState.error).toBeNull();
  });
  
  // Test multiple actions in sequence
  it('should handle multiple actions in sequence', () => {
    let state = authReducer(undefined, { type: undefined });
    
    // Set loading
    state = authReducer(state, setLoading(true));
    expect(state.isLoading).toBe(true);
    
    // Set user
    const user = {
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
    };
    state = authReducer(state, setUser(user));
    expect(state.user).toEqual(user);
    expect(state.isLoading).toBe(false);
    
    // Set error
    state = authReducer(state, setError('Something went wrong'));
    expect(state.error).toBe('Something went wrong');
    
    // Clear error
    state = authReducer(state, clearError());
    expect(state.error).toBeNull();
    
    // Logout
    state = authReducer(state, logout());
    expect(state.user).toBeNull();
  });
});
