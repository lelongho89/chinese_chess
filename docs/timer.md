# Chinese Chess Timer System

## Overview

The Chinese Chess game includes a timer system for blitz games with a 3+2 format (3 minutes initial time with 2 seconds increment per move). This document describes the timer system architecture, components, and integration with the game.

## Timer Architecture

The timer system consists of the following components:

1. **ChessTimer**: A model class that manages the timer state for a single player
2. **GameTimerManager**: A manager class that coordinates both player timers
3. **ChessTimerWidget**: A widget to display a single player's timer
4. **GameTimerDisplay**: A widget to display both player timers and controls
5. **WebSocketService**: A service for synchronizing timers in online games

## Timer Models

### ChessTimer

The `ChessTimer` class is responsible for managing the timer state for a single player. It includes:

- **State Management**: Ready, running, paused, expired, stopped
- **Time Tracking**: Accurate time tracking with millisecond precision
- **Increment Handling**: Adding time after a move (2 seconds)
- **Formatting**: Displaying time in mm:ss format

### GameTimerManager

The `GameTimerManager` class coordinates both player timers and integrates with the game manager. It includes:

- **Player Switching**: Switching the active timer when the player changes
- **Game Events**: Handling game events (load, player change, result)
- **Time Expiration**: Detecting when a player's time expires
- **Synchronization**: Methods for synchronizing timers in online games

## Timer UI Components

### ChessTimerWidget

The `ChessTimerWidget` displays a single player's timer with:

- **Time Display**: Shows the remaining time in mm:ss format
- **Color Coding**: Changes color based on time remaining (red for low time)
- **State Indicators**: Shows the current state (running, paused, expired)
- **Animations**: Smooth transitions and pulsing indicators

### GameTimerDisplay

The `GameTimerDisplay` shows both player timers and controls:

- **Player Timers**: Displays both red and black player timers
- **Timer Controls**: Enable/disable and reset buttons
- **Compact Mode**: Option for a more compact display on smaller screens

## Integration with Game Manager

The timer system integrates with the game manager through:

1. **Event System**: Listens for game events (player change, game load, game result)
2. **Player Switching**: Automatically switches the active timer when the player changes
3. **Time Expiration**: Notifies the game manager when a player's time expires
4. **Game Result**: Updates the game result when a player loses on time

## WebSocket Synchronization

For online games, the timer system includes WebSocket synchronization:

1. **Timer Updates**: Sends and receives timer updates
2. **Game Start/End**: Handles game start and end events
3. **Reconnection**: Handles reconnection and timer synchronization
4. **Error Handling**: Gracefully handles connection errors

## Timer Settings

The timer system supports the following settings:

1. **Initial Time**: 3 minutes (180 seconds) by default
2. **Increment**: 2 seconds per move by default
3. **Enable/Disable**: Option to enable or disable the timer
4. **Reset**: Option to reset the timers to the initial time

## Timer Behavior

The timer system behaves as follows:

1. **Game Start**: Both timers are reset to the initial time
2. **Player Move**: The active player's timer is running, the inactive player's timer is paused
3. **Move Completion**: The active player's timer is paused, the increment is added, and the other player's timer starts
4. **Time Expiration**: When a player's time reaches zero, they lose the game
5. **Game End**: Both timers are stopped when the game ends

## Implementation Details

### Accuracy

The timer uses a high-precision timer with 100ms updates to ensure accuracy. The actual time calculation is based on the elapsed time between updates, not on the timer interval, to prevent drift.

### Performance

The timer system is designed to be efficient and have minimal impact on game performance. It uses:

- **ChangeNotifier**: For efficient UI updates
- **Timer.periodic**: For accurate time tracking
- **Lazy Initialization**: To minimize resource usage

### Testing

The timer system includes comprehensive tests to ensure accuracy and reliability:

- **Unit Tests**: For timer models and logic
- **Widget Tests**: For timer UI components
- **Integration Tests**: For timer integration with the game

## Future Enhancements

Potential future enhancements include:

1. **Custom Time Controls**: Support for different time controls (e.g., 5+0, 1+1)
2. **Delay Mode**: Support for delay instead of increment
3. **Tournament Mode**: Support for tournament time controls
4. **Time Announcements**: Audio announcements for low time
5. **Time History**: Tracking and displaying time usage throughout the game
