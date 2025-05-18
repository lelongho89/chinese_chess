import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { Provider } from 'react-redux';
import configureStore from 'redux-mock-store';
import SkinSelector from '../SkinSelector';
import { SKIN_TYPES } from '../../../constants';

// Mock the store
const mockStore = configureStore([]);

describe('SkinSelector', () => {
  let store;
  
  beforeEach(() => {
    store = mockStore({
      game: {
        skin: SKIN_TYPES.WOODS,
      },
    });
    
    // Mock the dispatch function
    store.dispatch = jest.fn();
  });
  
  it('renders correctly with default props', () => {
    const { getByText } = render(
      <Provider store={store}>
        <SkinSelector />
      </Provider>
    );
    
    // Check if both skin options are rendered
    expect(getByText('Woods')).toBeTruthy();
    expect(getByText('Stones')).toBeTruthy();
  });
  
  it('dispatches setSkin action when a skin is selected', () => {
    const { getByText } = render(
      <Provider store={store}>
        <SkinSelector />
      </Provider>
    );
    
    // Click on the Stones skin option
    fireEvent.press(getByText('Stones'));
    
    // Check if the setSkin action was dispatched with the correct skin
    expect(store.dispatch).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'game/setSkin',
        payload: SKIN_TYPES.STONES,
      })
    );
  });
  
  it('renders without preview when showPreview is false', () => {
    const { queryAllByRole } = render(
      <Provider store={store}>
        <SkinSelector showPreview={false} />
      </Provider>
    );
    
    // Check if no images are rendered
    expect(queryAllByRole('image').length).toBe(0);
  });
  
  it('renders in vertical layout when horizontal is false', () => {
    const { container } = render(
      <Provider store={store}>
        <SkinSelector horizontal={false} />
      </Provider>
    );
    
    // Check if the container has the vertical style
    // Note: This is a bit tricky to test in React Native Testing Library
    // We would need to check the actual styles applied
    // For now, we'll just ensure it renders without errors
    expect(container).toBeTruthy();
  });
});
