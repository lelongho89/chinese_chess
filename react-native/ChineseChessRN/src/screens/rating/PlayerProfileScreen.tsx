import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  ActivityIndicator,
  Image,
  Dimensions,
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { useAppDispatch, useAppSelector } from '../../hooks';
import {
  getPlayerRating,
  getRatingHistory,
  getPlayerRank,
} from '../../store/actions';
import { LineChart } from 'react-native-chart-kit';
import Icon from 'react-native-vector-icons/MaterialIcons';

/**
 * Player profile screen component for the Chinese Chess application
 */
const PlayerProfileScreen: React.FC = () => {
  const route = useRoute<any>();
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  
  // Get state from Redux store
  const { playerRating, ratingHistory, playerRank, isLoading } = useAppSelector(state => state.rating);
  const currentUser = useAppSelector(state => state.auth.user);
  
  // Get user ID from route params or use current user ID
  const userId = route.params?.userId || currentUser?.id;
  
  // State for selected tab
  const [selectedTab, setSelectedTab] = useState<'stats' | 'history'>('stats');
  
  // Load player rating and history when the component mounts
  useEffect(() => {
    if (userId) {
      dispatch(getPlayerRating({ userId }));
      dispatch(getRatingHistory({ userId }));
      dispatch(getPlayerRank({ userId }));
    }
  }, [dispatch, userId]);
  
  // Format date
  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString();
  };
  
  // Get rating color based on rating value
  const getRatingColor = (rating: number) => {
    if (rating >= 2000) return '#FF6F00'; // Orange (Master)
    if (rating >= 1800) return '#9C27B0'; // Purple (Expert)
    if (rating >= 1600) return '#2196F3'; // Blue (Advanced)
    if (rating >= 1400) return '#4CAF50'; // Green (Intermediate)
    return '#757575'; // Grey (Beginner)
  };
  
  // Get rating title based on rating value
  const getRatingTitle = (rating: number) => {
    if (rating >= 2000) return 'Master';
    if (rating >= 1800) return 'Expert';
    if (rating >= 1600) return 'Advanced';
    if (rating >= 1400) return 'Intermediate';
    return 'Beginner';
  };
  
  // Prepare chart data
  const getChartData = () => {
    if (!ratingHistory || ratingHistory.length === 0) {
      return {
        labels: ['No Data'],
        datasets: [
          {
            data: [1200],
            color: () => '#ccc',
          },
        ],
      };
    }
    
    // Sort history by date
    const sortedHistory = [...ratingHistory].sort((a, b) => a.date - b.date);
    
    // Get last 10 entries
    const recentHistory = sortedHistory.slice(-10);
    
    return {
      labels: recentHistory.map(() => ''), // Empty labels for cleaner look
      datasets: [
        {
          data: recentHistory.map(entry => entry.rating),
          color: (opacity = 1) => `rgba(244, 81, 30, ${opacity})`,
        },
      ],
    };
  };
  
  // Calculate win rate
  const calculateWinRate = () => {
    if (!playerRating || playerRating.gamesPlayed === 0) return 0;
    return Math.round((playerRating.gamesWon / playerRating.gamesPlayed) * 100);
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
        
        <Text style={styles.title}>Player Profile</Text>
        
        <View style={styles.placeholder} />
      </View>
      
      {isLoading || !playerRating ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#f4511e" />
          <Text style={styles.loadingText}>Loading player profile...</Text>
        </View>
      ) : (
        <ScrollView style={styles.content}>
          <View style={styles.profileHeader}>
            <View style={styles.avatarContainer}>
              {playerRating.displayName ? (
                <View style={[
                  styles.avatarFallback,
                  { backgroundColor: getRatingColor(playerRating.rating) }
                ]}>
                  <Text style={styles.avatarText}>
                    {playerRating.displayName.charAt(0).toUpperCase()}
                  </Text>
                </View>
              ) : (
                <View style={styles.avatarFallback}>
                  <Icon name="person" size={40} color="#fff" />
                </View>
              )}
            </View>
            
            <View style={styles.profileInfo}>
              <Text style={styles.playerName}>{playerRating.displayName}</Text>
              <View style={styles.ratingContainer}>
                <Text style={styles.ratingText}>{playerRating.rating}</Text>
                <Text style={styles.ratingTitle}>
                  {getRatingTitle(playerRating.rating)}
                </Text>
              </View>
              <Text style={styles.rankText}>Rank: #{playerRank}</Text>
            </View>
          </View>
          
          <View style={styles.tabContainer}>
            <TouchableOpacity
              style={[
                styles.tabButton,
                selectedTab === 'stats' && styles.activeTabButton,
              ]}
              onPress={() => setSelectedTab('stats')}
            >
              <Text style={[
                styles.tabButtonText,
                selectedTab === 'stats' && styles.activeTabButtonText,
              ]}>
                Stats
              </Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[
                styles.tabButton,
                selectedTab === 'history' && styles.activeTabButton,
              ]}
              onPress={() => setSelectedTab('history')}
            >
              <Text style={[
                styles.tabButtonText,
                selectedTab === 'history' && styles.activeTabButtonText,
              ]}>
                History
              </Text>
            </TouchableOpacity>
          </View>
          
          {selectedTab === 'stats' ? (
            <View style={styles.statsContainer}>
              <View style={styles.statsRow}>
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>{playerRating.gamesPlayed}</Text>
                  <Text style={styles.statLabel}>Games</Text>
                </View>
                
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>{calculateWinRate()}%</Text>
                  <Text style={styles.statLabel}>Win Rate</Text>
                </View>
                
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>{playerRating.gamesWon}</Text>
                  <Text style={styles.statLabel}>Wins</Text>
                </View>
              </View>
              
              <View style={styles.statsRow}>
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>{playerRating.gamesLost}</Text>
                  <Text style={styles.statLabel}>Losses</Text>
                </View>
                
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>{playerRating.gamesDraw}</Text>
                  <Text style={styles.statLabel}>Draws</Text>
                </View>
                
                <View style={styles.statItem}>
                  <Text style={styles.statValue}>
                    {playerRating.lastPlayed ? formatDate(playerRating.lastPlayed) : 'N/A'}
                  </Text>
                  <Text style={styles.statLabel}>Last Game</Text>
                </View>
              </View>
              
              <View style={styles.chartContainer}>
                <Text style={styles.chartTitle}>Rating History</Text>
                {ratingHistory.length > 0 ? (
                  <LineChart
                    data={getChartData()}
                    width={Dimensions.get('window').width - 32}
                    height={220}
                    chartConfig={{
                      backgroundColor: '#fff',
                      backgroundGradientFrom: '#fff',
                      backgroundGradientTo: '#fff',
                      decimalPlaces: 0,
                      color: (opacity = 1) => `rgba(244, 81, 30, ${opacity})`,
                      labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
                      style: {
                        borderRadius: 16,
                      },
                      propsForDots: {
                        r: '6',
                        strokeWidth: '2',
                        stroke: '#f4511e',
                      },
                    }}
                    bezier
                    style={styles.chart}
                  />
                ) : (
                  <View style={styles.noChartData}>
                    <Text style={styles.noChartDataText}>No rating history available</Text>
                  </View>
                )}
              </View>
            </View>
          ) : (
            <View style={styles.historyContainer}>
              {ratingHistory.length === 0 ? (
                <View style={styles.emptyHistory}>
                  <Icon name="history" size={60} color="#ccc" />
                  <Text style={styles.emptyHistoryText}>No rating history available</Text>
                </View>
              ) : (
                ratingHistory.slice().reverse().map((entry, index) => (
                  <View key={index} style={styles.historyItem}>
                    <View style={styles.historyDate}>
                      <Text style={styles.historyDateText}>{formatDate(entry.date)}</Text>
                    </View>
                    
                    <View style={styles.historyDetails}>
                      <Text style={styles.historyOpponent}>
                        vs {entry.opponentName} ({entry.opponentRating})
                      </Text>
                      
                      <View style={[
                        styles.historyResult,
                        entry.result === 'win' && styles.historyWin,
                        entry.result === 'loss' && styles.historyLoss,
                        entry.result === 'draw' && styles.historyDraw,
                      ]}>
                        <Text style={styles.historyResultText}>
                          {entry.result.toUpperCase()}
                        </Text>
                      </View>
                    </View>
                    
                    <View style={styles.historyRating}>
                      <Text style={[
                        styles.historyRatingChange,
                        entry.change > 0 && styles.ratingIncrease,
                        entry.change < 0 && styles.ratingDecrease,
                      ]}>
                        {entry.change > 0 ? '+' : ''}{entry.change}
                      </Text>
                      <Text style={styles.historyRatingValue}>{entry.rating}</Text>
                    </View>
                  </View>
                ))
              )}
            </View>
          )}
        </ScrollView>
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
  content: {
    flex: 1,
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  avatarContainer: {
    marginRight: 16,
  },
  avatarFallback: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#f4511e',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#fff',
  },
  profileInfo: {
    flex: 1,
  },
  playerName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  ratingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  ratingText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#f4511e',
    marginRight: 8,
  },
  ratingTitle: {
    fontSize: 14,
    color: '#666',
  },
  rankText: {
    fontSize: 14,
    color: '#666',
  },
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#fff',
    marginBottom: 16,
  },
  tabButton: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
  },
  activeTabButton: {
    borderBottomWidth: 2,
    borderBottomColor: '#f4511e',
  },
  tabButtonText: {
    fontSize: 16,
    color: '#666',
  },
  activeTabButtonText: {
    color: '#f4511e',
    fontWeight: 'bold',
  },
  statsContainer: {
    padding: 16,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 8,
    marginHorizontal: 4,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
  },
  statValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
  },
  chartContainer: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginTop: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 1.41,
  },
  chartTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 16,
  },
  chart: {
    borderRadius: 8,
  },
  noChartData: {
    height: 220,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noChartDataText: {
    fontSize: 14,
    color: '#999',
  },
  historyContainer: {
    padding: 16,
  },
  emptyHistory: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
  },
  emptyHistoryText: {
    fontSize: 16,
    color: '#999',
    marginTop: 16,
  },
  historyItem: {
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
  historyDate: {
    width: 70,
  },
  historyDateText: {
    fontSize: 12,
    color: '#666',
  },
  historyDetails: {
    flex: 1,
  },
  historyOpponent: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4,
  },
  historyResult: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
    alignSelf: 'flex-start',
    backgroundColor: '#e0e0e0',
  },
  historyWin: {
    backgroundColor: '#e8f5e9',
  },
  historyLoss: {
    backgroundColor: '#ffebee',
  },
  historyDraw: {
    backgroundColor: '#e3f2fd',
  },
  historyResultText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#333',
  },
  historyRating: {
    alignItems: 'flex-end',
  },
  historyRatingChange: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 2,
  },
  ratingIncrease: {
    color: '#4caf50',
  },
  ratingDecrease: {
    color: '#f44336',
  },
  historyRatingValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#f4511e',
  },
});

export default PlayerProfileScreen;
