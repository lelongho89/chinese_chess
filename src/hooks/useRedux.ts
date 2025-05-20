import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import type { RootState } from '../store/rootReducer';
import type { AppDispatch } from '../store';

/**
 * Custom hook for accessing the Redux dispatch function with correct typing
 */
export const useAppDispatch = () => useDispatch<AppDispatch>();

/**
 * Custom hook for accessing the Redux store state with correct typing
 */
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
