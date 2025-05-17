import React from 'react';
import { TouchableOpacity, Text } from 'react-native';
import { render, fireEvent } from '../../utils/testing/test-utils';

// Simple Button component for testing
const Button = ({ title, onPress }: { title: string; onPress: () => void }) => (
  <TouchableOpacity onPress={onPress} testID="button">
    <Text testID="button-text">{title}</Text>
  </TouchableOpacity>
);

describe('Button Component', () => {
  it('renders correctly with the given title', () => {
    const { getByTestId } = render(<Button title="Press Me" onPress={() => {}} />);
    
    const buttonText = getByTestId('button-text');
    expect(buttonText).toBeTruthy();
    expect(buttonText.props.children).toBe('Press Me');
  });
  
  it('calls onPress when pressed', () => {
    const onPressMock = jest.fn();
    const { getByTestId } = render(<Button title="Press Me" onPress={onPressMock} />);
    
    const button = getByTestId('button');
    fireEvent.press(button);
    
    expect(onPressMock).toHaveBeenCalledTimes(1);
  });
});
