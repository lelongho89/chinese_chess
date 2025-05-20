import React from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

interface TimerControlsProps {
  isEnabled: boolean;
  onToggleEnabled: () => void;
  onReset: () => void;
}

/**
 * Component for timer controls (enable/disable, reset)
 */
const TimerControls: React.FC<TimerControlsProps> = ({
  isEnabled,
  onToggleEnabled,
  onReset,
}) => {
  return (
    <View style={styles.container}>
      {/* Enable/disable toggle */}
      <View style={styles.toggleContainer}>
        <Switch
          value={isEnabled}
          onValueChange={onToggleEnabled}
          trackColor={{ false: '#767577', true: '#81b0ff' }}
          thumbColor={isEnabled ? '#2196F3' : '#f4f3f4'}
        />
        <Text
          style={[
            styles.toggleText,
            { color: isEnabled ? '#4CAF50' : '#9E9E9E' },
          ]}
        >
          {isEnabled ? 'Timer Enabled' : 'Timer Disabled'}
        </Text>
      </View>

      {/* Reset button (only shown when timer is enabled) */}
      {isEnabled && (
        <TouchableOpacity
          style={styles.resetButton}
          onPress={onReset}
          activeOpacity={0.7}
        >
          <Icon name="refresh" size={20} color="#2196F3" />
        </TouchableOpacity>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
  },
  toggleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  toggleText: {
    marginLeft: 8,
    fontSize: 14,
  },
  resetButton: {
    marginLeft: 16,
    padding: 8,
  },
});

export default TimerControls;
