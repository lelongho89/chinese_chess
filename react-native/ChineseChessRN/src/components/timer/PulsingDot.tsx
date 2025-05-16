import React, { useEffect, useRef } from 'react';
import { View, Animated, StyleSheet } from 'react-native';

interface PulsingDotProps {
  color: string;
  size?: number;
}

/**
 * A pulsing dot component to indicate an active timer
 */
const PulsingDot: React.FC<PulsingDotProps> = ({ color, size = 8 }) => {
  // Animation value for scaling
  const scaleAnim = useRef(new Animated.Value(1)).current;
  
  // Start the pulsing animation when the component mounts
  useEffect(() => {
    // Create a sequence of animations
    Animated.loop(
      Animated.sequence([
        // Scale up
        Animated.timing(scaleAnim, {
          toValue: 1.5,
          duration: 500,
          useNativeDriver: true,
        }),
        // Scale down
        Animated.timing(scaleAnim, {
          toValue: 1,
          duration: 500,
          useNativeDriver: true,
        }),
      ])
    ).start();
    
    // Clean up animation when component unmounts
    return () => {
      scaleAnim.stopAnimation();
    };
  }, [scaleAnim]);
  
  return (
    <Animated.View
      style={[
        styles.dot,
        {
          backgroundColor: color,
          width: size,
          height: size,
          borderRadius: size / 2,
          transform: [{ scale: scaleAnim }],
        },
      ]}
    />
  );
};

const styles = StyleSheet.create({
  dot: {
    margin: 4,
  },
});

export default PulsingDot;
