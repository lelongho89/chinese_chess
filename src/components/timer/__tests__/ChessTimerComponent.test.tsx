import React from 'react';
import { render } from '@testing-library/react-native';
import ChessTimerComponent from '../ChessTimerComponent';
import { TimerState } from '../../../models/ChessTimer';

describe('ChessTimerComponent', () => {
  it('renders correctly with default props', () => {
    const { getByText } = render(
      <ChessTimerComponent
        time="03:00"
        timerState={TimerState.READY}
        isActive={false}
        color="#ff0000"
      />
    );
    
    expect(getByText('03:00')).toBeTruthy();
  });
  
  it('shows active state when isActive is true', () => {
    const { getByText } = render(
      <ChessTimerComponent
        time="03:00"
        timerState={TimerState.RUNNING}
        isActive={true}
        color="#ff0000"
      />
    );
    
    const timeText = getByText('03:00');
    expect(timeText.props.style).toContainEqual(expect.objectContaining({
      fontWeight: 'bold'
    }));
  });
  
  it('renders in compact mode when isCompact is true', () => {
    const { getByText } = render(
      <ChessTimerComponent
        time="03:00"
        timerState={TimerState.READY}
        isActive={false}
        color="#ff0000"
        isCompact={true}
      />
    );
    
    const timeText = getByText('03:00');
    expect(timeText.props.style).toContainEqual(expect.objectContaining({
      fontSize: 16
    }));
  });
});
