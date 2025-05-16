import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useAppDispatch, useAppSelector } from '../../hooks';
import { getLeaderboard } from '../../store/actions';
import { LeaderboardEntry } from '../../services/rating';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Leaderboard screen component for the Chinese Chess application
 */
const LeaderboardScreen: React.FC = () => {
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  
  // Get state from Redux store
  const { leaderboard, isLoading } = useAppSelector(state => state.rating);
  const currentUser = useAppSelector(state => state.auth.user);
  
  // State for refreshing
  const [refreshing, setRefreshing] = useState(false);
  
  // Load leaderboard when the component mounts
  useEffect(() => {
    dispatch(getLeaderboard({ limit: 100 }));
  }, [dispatch]);
  
  // Handle refresh
  const handleRefresh = async () => {
    setRefreshing(true);
    await dispatch(getLeaderboard({ limit: 100 }));
    setRefreshing(false);
  };
  
  // Render medal icon based on rank
  const renderMedal = (rank: number) => {
    if (rank === 1) {
      return <Icon name="emoji-events" size={24} color="#FFD700" />;
    } else if (rank === 2) {
      return <Icon name="emoji-events" size={24} color="#C0C0C0" />;
    } else if (rank === 3) {
      return <Icon name="emoji-events" size={24} color="#CD7F32" />;
    } else {
      return <Text style={styles.rankText}>{rank}</Text>;
    }
  };
  
  // Render leaderboard item
  const renderLeaderboardItem = ({ item }: { item: LeaderboardEntry }) => {
    const isCurrentUser = currentUser && item.userId === currentUser.id;
    
    return (
      <TouchableOpacity
        style={[
          styles.leaderboardItem,
          isCurrentUser && styles.currentUserItem,
        ]}
        onPress={() => navigation.navigate('PlayerProfile' as never, { userId: item.userId } as never)}
      >
        <View style={styles.rankContainer}>
          {renderMedal(item.rank)}
        </View>
        
        <View style={styles.playerInfo}>
          <Text style={styles.playerName}>
            {item.displayName}
            {isCurrentUser && ' (You)'}
          </Text>
          <Text style={styles.playerStats}>
            Games: {item.gamesPlayed} | Win Rate: {item.winRate}%
          </Text>
        </View>
        
        <View style={styles.ratingContainer}>
          <Text style={styles.ratingText}>{item.rating}</Text>
        </View>
      </TouchableOpacity>
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
        
        <Text style={styles.title}>Leaderboard</Text>
        
        <View style={styles.placeholder} />
      </View>
      
      {isLoading && !refreshing ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#f4511e" />
          <Text style={styles.loadingText}>Loading leaderboard...</Text>
        </View>
      ) : leaderboard.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Icon name="leaderboard" size={80} color="#ccc" />
          <Text style={styles.emptyText}>No players found</Text>
          <Text style={styles.emptySubtext}>
            Players need to complete at least 5 games to be ranked
          </Text>
        </View>
      ) : (
        <FlatList
          data={leaderboard}
          renderItem={renderLeaderboardItem}
          keyExtractor={item => item.userId}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={handleRefresh}
              colors={['#f4511e']}
            />
          }
          ListHeaderComponent={
            <View style={styles.listHeader}>
              <View style={styles.rankHeaderContainer}>
                <Text style={styles.headerText}>Rank</Text>
              </View>
              <View style={styles.playerHeaderInfo}>
                <Text style={styles.headerText}>Player</Text>
              </View>
              <View style={styles.ratingHeaderContainer}>
                <Text style={styles.headerText}>Rating</Text>
              </View>
            </View>
          }
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
  placeholder: {
    width: 40,
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
  listHeader: {
    flexDirection: 'row',
    paddingVertical: 8,
    marginBottom: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  rankHeaderContainer: {
    width: 50,
    alignItems: 'center',
  },
  playerHeaderInfo: {
    flex: 1,
  },
  ratingHeaderContainer: {
    width: 60,
    alignItems: 'center',
  },
  headerText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#666',
  },
  leaderboardItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    borderRadius: 8,
    marginBottom: 8,
    padding: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
  },
  currentUserItem: {
    backgroundColor: '#fff9c4',
  },
  rankContainer: {
    width: 50,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rankText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  playerInfo: {
    flex: 1,
    marginLeft: 8,
  },
  playerName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  playerStats: {
    fontSize: 12,
    color: '#666',
  },
  ratingContainer: {
    backgroundColor: '#f4511e',
    borderRadius: 16,
    paddingVertical: 4,
    paddingHorizontal: 8,
    minWidth: 60,
    alignItems: 'center',
  },
  ratingText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#fff',
  },
});

export default LeaderboardScreen;
