import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
  SafeAreaView,
  ActivityIndicator,
  Share,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAppDispatch, useAppSelector } from '../../hooks';
import {
  getGameHistory,
  deleteGameFromHistory,
  clearGameHistory,
  exportGameAsPGN,
} from '../../store/actions';
import { GameHistoryEntry } from '../../services/history';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Game history screen component for the Chinese Chess application
 */
const GameHistoryScreen: React.FC = () => {
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  
  // Get state from Redux store
  const { savedGames, isLoading } = useAppSelector(state => state.game);
  const user = useAppSelector(state => state.auth.user);
  
  // State for selected game
  const [selectedGameId, setSelectedGameId] = useState<string | null>(null);
  
  // Load game history when the component mounts
  useEffect(() => {
    dispatch(getGameHistory());
  }, [dispatch]);
  
  // Handle game selection
  const handleGameSelect = (gameId: string) => {
    setSelectedGameId(gameId === selectedGameId ? null : gameId);
  };
  
  // Handle game replay
  const handleReplay = (game: GameHistoryEntry) => {
    navigation.navigate('GameReplay' as never, { gameId: game.id } as never);
  };
  
  // Handle game deletion
  const handleDelete = (gameId: string) => {
    Alert.alert(
      'Delete Game',
      'Are you sure you want to delete this game?',
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            dispatch(deleteGameFromHistory({ gameId }));
            setSelectedGameId(null);
          },
        },
      ]
    );
  };
  
  // Handle clear history
  const handleClearHistory = () => {
    Alert.alert(
      'Clear History',
      'Are you sure you want to clear all game history?',
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Clear',
          style: 'destructive',
          onPress: () => {
            dispatch(clearGameHistory());
            setSelectedGameId(null);
          },
        },
      ]
    );
  };
  
  // Handle game export
  const handleExport = async (game: GameHistoryEntry) => {
    try {
      // Export the game as PGN
      const pgn = await dispatch(exportGameAsPGN({ game })).unwrap();
      
      // Share the PGN
      await Share.share({
        message: pgn,
        title: 'Chinese Chess Game PGN',
      });
    } catch (error) {
      console.error('Error exporting game:', error);
      Alert.alert('Export Failed', 'Failed to export game');
    }
  };
  
  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  };
  
  // Render game item
  const renderGameItem = ({ item }: { item: GameHistoryEntry }) => {
    const isSelected = item.id === selectedGameId;
    
    return (
      <View style={styles.gameItemContainer}>
        <TouchableOpacity
          style={[
            styles.gameItem,
            isSelected && styles.selectedGameItem,
          ]}
          onPress={() => handleGameSelect(item.id)}
        >
          <View style={styles.gameInfo}>
            <Text style={styles.gameDate}>{formatDate(item.date)}</Text>
            <Text style={styles.gameMode}>Mode: {item.gameMode}</Text>
            <Text style={styles.gameResult}>
              Result: {item.result === 'win' ? 'Win' : item.result === 'loss' ? 'Loss' : 'Draw'}
            </Text>
            <Text style={styles.gameOpponent}>
              Opponent: {item.opponent}
            </Text>
          </View>
          <Icon
            name={isSelected ? 'keyboard-arrow-up' : 'keyboard-arrow-down'}
            size={24}
            color="#666"
          />
        </TouchableOpacity>
        
        {isSelected && (
          <View style={styles.gameActions}>
            <TouchableOpacity
              style={styles.actionButton}
              onPress={() => handleReplay(item)}
            >
              <Icon name="replay" size={20} color="#fff" />
              <Text style={styles.actionButtonText}>Replay</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={styles.actionButton}
              onPress={() => handleExport(item)}
            >
              <Icon name="share" size={20} color="#fff" />
              <Text style={styles.actionButtonText}>Export</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.actionButton, styles.deleteButton]}
              onPress={() => handleDelete(item.id)}
            >
              <Icon name="delete" size={20} color="#fff" />
              <Text style={styles.actionButtonText}>Delete</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>
    );
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        
        <Text style={styles.title}>Game History</Text>
        
        <TouchableOpacity
          style={styles.clearButton}
          onPress={handleClearHistory}
          disabled={savedGames.length === 0}
        >
          <Icon
            name="delete-sweep"
            size={24}
            color={savedGames.length === 0 ? '#ccc' : '#f44336'}
          />
        </TouchableOpacity>
      </View>
      
      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#f4511e" />
          <Text style={styles.loadingText}>Loading game history...</Text>
        </View>
      ) : savedGames.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Icon name="history" size={80} color="#ccc" />
          <Text style={styles.emptyText}>No game history found</Text>
          <Text style={styles.emptySubtext}>
            Your completed games will appear here
          </Text>
        </View>
      ) : (
        <FlatList
          data={savedGames}
          renderItem={renderGameItem}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
        />
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButton: {
    padding: 8,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  clearButton: {
    padding: 8,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#666',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#666',
    marginTop: 20,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    marginTop: 10,
    textAlign: 'center',
  },
  listContent: {
    padding: 16,
  },
  gameItemContainer: {
    marginBottom: 12,
    borderRadius: 8,
    overflow: 'hidden',
    backgroundColor: '#fff',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
  },
  gameItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
  },
  selectedGameItem: {
    backgroundColor: '#f5f5f5',
  },
  gameInfo: {
    flex: 1,
  },
  gameDate: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  gameMode: {
    fontSize: 12,
    color: '#666',
  },
  gameResult: {
    fontSize: 12,
    color: '#666',
  },
  gameOpponent: {
    fontSize: 12,
    color: '#666',
  },
  gameActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 12,
    backgroundColor: '#f9f9f9',
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2196f3',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 4,
  },
  deleteButton: {
    backgroundColor: '#f44336',
  },
  actionButtonText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
    marginLeft: 4,
  },
});

export default GameHistoryScreen;
