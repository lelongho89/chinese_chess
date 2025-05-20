import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import { configureStore } from '@reduxjs/toolkit';
import rootReducer from '../../../store/rootReducer';
import { authService, userService } from '../services';
import { Text, TouchableOpacity, View } from 'react-native';
import { login, register, logout } from '../../../store/actions/authActions';

// Mock Firebase Auth
jest.mock('@react-native-firebase/auth', () => {
  const mockAuth = {
    signInWithEmailAndPassword: jest.fn(),
    createUserWithEmailAndPassword: jest.fn(),
    signOut: jest.fn(),
    currentUser: {
      updateProfile: jest.fn(),
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

// Create a test component that uses Firebase services
const TestComponent = ({ 
  onLogin, 
  onRegister, 
  onLogout, 
  onUpdateProfile,
  onGetProfile
}) => {
  return (
    <View>
      <TouchableOpacity testID="login-button" onPress={onLogin}>
        <Text>Login</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="register-button" onPress={onRegister}>
        <Text>Register</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="logout-button" onPress={onLogout}>
        <Text>Logout</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="update-profile-button" onPress={onUpdateProfile}>
        <Text>Update Profile</Text>
      </TouchableOpacity>
      
      <TouchableOpacity testID="get-profile-button" onPress={onGetProfile}>
        <Text>Get Profile</Text>
      </TouchableOpacity>
    </View>
  );
};

describe('Firebase Integration', () => {
  // Set up test store
  let store;
  
  beforeEach(() => {
    store = configureStore({
      reducer: rootReducer,
      middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
          serializableCheck: false,
          immutableCheck: false,
        }),
    });
    
    // Reset mocks
    jest.clearAllMocks();
  });
  
  it('dispatches login action and updates Redux state', async () => {
    // Mock successful login
    const mockUser = { uid: 'test-uid', email: 'test@example.com' };
    const mockUserData = { displayName: 'Test User', photoURL: 'https://example.com/photo.jpg' };
    
    (authService.signIn as jest.Mock) = jest.fn().mockResolvedValue({
      id: mockUser.uid,
      email: mockUser.email,
      displayName: mockUserData.displayName,
      photoURL: mockUserData.photoURL,
    });
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => store.dispatch(login({ email: 'test@example.com', password: 'password123' }))}
          onRegister={() => {}}
          onLogout={() => {}}
          onUpdateProfile={() => {}}
          onGetProfile={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().auth.user).toBeNull();
    expect(store.getState().auth.isLoading).toBe(false);
    
    // Login
    fireEvent.press(getByTestId('login-button'));
    
    // Check loading state
    expect(store.getState().auth.isLoading).toBe(true);
    
    // Wait for login to complete
    await waitFor(() => {
      expect(store.getState().auth.isLoading).toBe(false);
      expect(store.getState().auth.user).not.toBeNull();
    });
    
    // Check that the user is set
    expect(store.getState().auth.user).toEqual({
      id: mockUser.uid,
      email: mockUser.email,
      displayName: mockUserData.displayName,
      photoURL: mockUserData.photoURL,
    });
  });
  
  it('dispatches register action and updates Redux state', async () => {
    // Mock successful registration
    const mockUser = { uid: 'test-uid', email: 'test@example.com' };
    
    (authService.signUp as jest.Mock) = jest.fn().mockResolvedValue({
      id: mockUser.uid,
      email: mockUser.email,
      displayName: 'Test User',
      photoURL: null,
    });
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => {}}
          onRegister={() => store.dispatch(register({
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          }))}
          onLogout={() => {}}
          onUpdateProfile={() => {}}
          onGetProfile={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().auth.user).toBeNull();
    expect(store.getState().auth.isLoading).toBe(false);
    
    // Register
    fireEvent.press(getByTestId('register-button'));
    
    // Check loading state
    expect(store.getState().auth.isLoading).toBe(true);
    
    // Wait for registration to complete
    await waitFor(() => {
      expect(store.getState().auth.isLoading).toBe(false);
      expect(store.getState().auth.user).not.toBeNull();
    });
    
    // Check that the user is set
    expect(store.getState().auth.user).toEqual({
      id: mockUser.uid,
      email: mockUser.email,
      displayName: 'Test User',
      photoURL: null,
    });
  });
  
  it('dispatches logout action and updates Redux state', async () => {
    // Set initial state with a logged-in user
    store.dispatch({
      type: 'auth/setUser',
      payload: {
        id: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: null,
      },
    });
    
    // Mock successful logout
    (authService.signOut as jest.Mock) = jest.fn().mockResolvedValue(undefined);
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => {}}
          onRegister={() => {}}
          onLogout={() => store.dispatch(logout())}
          onUpdateProfile={() => {}}
          onGetProfile={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().auth.user).not.toBeNull();
    
    // Logout
    fireEvent.press(getByTestId('logout-button'));
    
    // Wait for logout to complete
    await waitFor(() => {
      expect(store.getState().auth.user).toBeNull();
    });
  });
  
  it('updates user profile and reflects changes in Redux state', async () => {
    // Set initial state with a logged-in user
    store.dispatch({
      type: 'auth/setUser',
      payload: {
        id: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: null,
      },
    });
    
    // Mock successful profile update
    (userService.updateUserProfile as jest.Mock) = jest.fn().mockResolvedValue(undefined);
    
    // Render the test component
    const { getByTestId } = render(
      <Provider store={store}>
        <TestComponent
          onLogin={() => {}}
          onRegister={() => {}}
          onLogout={() => {}}
          onUpdateProfile={() => {
            userService.updateUserProfile('test-uid', {
              displayName: 'Updated Name',
              photoURL: 'https://example.com/new-photo.jpg',
            }).then(() => {
              // Update the user in Redux
              store.dispatch({
                type: 'auth/setUser',
                payload: {
                  ...store.getState().auth.user,
                  displayName: 'Updated Name',
                  photoURL: 'https://example.com/new-photo.jpg',
                },
              });
            });
          }}
          onGetProfile={() => {}}
        />
      </Provider>
    );
    
    // Check initial state
    expect(store.getState().auth.user.displayName).toBe('Test User');
    expect(store.getState().auth.user.photoURL).toBeNull();
    
    // Update profile
    fireEvent.press(getByTestId('update-profile-button'));
    
    // Wait for update to complete
    await waitFor(() => {
      expect(store.getState().auth.user.displayName).toBe('Updated Name');
      expect(store.getState().auth.user.photoURL).toBe('https://example.com/new-photo.jpg');
    });
  });
});
