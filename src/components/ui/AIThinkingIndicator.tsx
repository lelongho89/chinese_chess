import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { useLocalization } from '../../hooks/useLocalization';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Props for the AIThinkingIndicator component
 */
interface AIThinkingIndicatorProps {
  isThinking: boolean;
  difficulty?: 'easy' | 'medium' | 'hard';
}

/**
 * AIThinkingIndicator component for the Chinese Chess game
 * This component displays an indicator when the AI is thinking
 */
const AIThinkingIndicator: React.FC<AIThinkingIndicatorProps> = ({
  isThinking,
  difficulty = 'medium',
}) => {
  // Use the localization hook
  const { t } = useLocalization();
  
  // Animation value for the thinking indicator
  const opacityAnim = useRef(new Animated.Value(1)).current;
  
  // Start the animation when the component mounts or when isThinking changes
  useEffect(() => {
    if (isThinking) {
      // Create a sequence of animations
      Animated.loop(
        Animated.sequence([
          // Fade out
          Animated.timing(opacityAnim, {
            toValue: 0.3,
            duration: 800,
            useNativeDriver: true,
          }),
          // Fade in
          Animated.timing(opacityAnim, {
            toValue: 1,
            duration: 800,
            useNativeDriver: true,
          }),
        ])
      ).start();
    } else {
      // Stop the animation
      opacityAnim.stopAnimation();
      // Reset the opacity
      Animated.timing(opacityAnim, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }).start();
    }
    
    // Clean up animation when component unmounts
    return () => {
      opacityAnim.stopAnimation();
    };
  }, [isThinking, opacityAnim]);
  
  // If not thinking, don't render anything
  if (!isThinking) {
    return null;
  }
  
  // Get the icon based on difficulty
  const getIcon = () => {
    switch (difficulty) {
      case 'easy':
        return 'sentiment-satisfied';
      case 'medium':
        return 'sentiment-neutral';
      case 'hard':
        return 'sentiment-very-dissatisfied';
      default:
        return 'psychology';
    }
  };
  
  return (
    <Animated.View
      style={[
        styles.container,
        { opacity: opacityAnim },
      ]}
    >
      <Icon name={getIcon()} size={24} color="#f4511e" />
      <Text style={styles.text}>{t('game.thinking')}</Text>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#f4511e',
    marginVertical: 8,
  },
  text: {
    marginLeft: 8,
    fontSize: 16,
    fontWeight: 'bold',
    color: '#f4511e',
  },
});

export default AIThinkingIndicator;
