import { configureStore } from '@reduxjs/toolkit';
import { persistStore, persistReducer } from 'redux-persist';
import AsyncStorage from '@react-native-async-storage/async-storage';
import thunk from 'redux-thunk';
import rootReducer from './rootReducer';

/**
 * Configuration for Redux Persist
 */
const persistConfig = {
  key: 'root',
  storage: AsyncStorage,
  // Whitelist (save specific reducers)
  whitelist: ['settings', 'auth'],
  // Blacklist (don't save specific reducers)
  blacklist: [],
};

/**
 * Persisted reducer
 */
const persistedReducer = persistReducer(persistConfig, rootReducer);

/**
 * Redux store configuration
 */
export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        // Ignore these action types
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
        // Ignore these field paths in all actions
        ignoredActionPaths: ['meta.arg', 'payload.timestamp'],
        // Ignore these paths in the state
        ignoredPaths: ['items.dates'],
      },
    }).concat(thunk),
  devTools: __DEV__,
});

/**
 * Persistor for the Redux store
 */
export const persistor = persistStore(store);

/**
 * Redux store types
 */
export type AppDispatch = typeof store.dispatch;
export type RootState = ReturnType<typeof store.getState>;

/**
 * Export selectors
 */
export * from './selectors';

/**
 * Export actions
 */
export * from './slices/gameSlice';
export * from './slices/settingsSlice';
export * from './slices/authSlice';
