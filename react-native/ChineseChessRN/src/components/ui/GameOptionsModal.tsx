import React from 'react';
import { View, Text, StyleSheet, Modal, TouchableOpacity, TouchableWithoutFeedback } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAppDispatch } from '../../hooks';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { initGame } from '../../store/actions';

/**
 * Props for the GameOptionsModal component
 */
interface GameOptionsModalProps {
  visible: boolean;
  onClose: () => void;
  gameMode: string;
}

/**
 * GameOptionsModal component for the Chinese Chess game
 * This component displays a modal with game options
 */
const GameOptionsModal: React.FC<GameOptionsModalProps> = ({ 
  visible,
  onClose,
  gameMode
}) => {
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  
  // Handle restart game
  const handleRestart = () => {
    dispatch(initGame({ gameMode: gameMode as 'ai' | 'online' | 'free' }));
    onClose();
  };
  
  // Handle go to home
  const handleGoToHome = () => {
    onClose();
    navigation.navigate('Home' as never);
  };
  
  // Handle go to settings
  const handleGoToSettings = () => {
    onClose();
    navigation.navigate('Settings' as never);
  };
  
  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <TouchableWithoutFeedback onPress={onClose}>
        <View style={styles.modalOverlay}>
          <TouchableWithoutFeedback>
            <View style={styles.modalContent}>
              <Text style={styles.modalTitle}>Game Options</Text>
              
              <TouchableOpacity style={styles.option} onPress={handleRestart}>
                <Icon name="refresh" size={24} color="#333" />
                <Text style={styles.optionText}>Restart Game</Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.option} onPress={handleGoToSettings}>
                <Icon name="settings" size={24} color="#333" />
                <Text style={styles.optionText}>Settings</Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.option} onPress={handleGoToHome}>
                <Icon name="home" size={24} color="#333" />
                <Text style={styles.optionText}>Back to Home</Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.closeButton} onPress={onClose}>
                <Text style={styles.closeButtonText}>Close</Text>
              </TouchableOpacity>
            </View>
          </TouchableWithoutFeedback>
        </View>
      </TouchableWithoutFeedback>
    </Modal>
  );
};

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 16,
    width: '80%',
    maxWidth: 300,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  optionText: {
    fontSize: 16,
    marginLeft: 16,
  },
  closeButton: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#f5f5f5',
    borderRadius: 4,
    alignItems: 'center',
  },
  closeButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
});

export default GameOptionsModal;
