import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView, Linking, TouchableOpacity } from 'react-native';

/**
 * About screen component for the Chinese Chess application
 */
const AboutScreen: React.FC = () => {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.section}>
          <Text style={styles.title}>Chinese Chess (Xiangqi)</Text>
          <Text style={styles.version}>Version 1.0.0</Text>
          
          <Text style={styles.sectionTitle}>Description</Text>
          <Text style={styles.paragraph}>
            A modern implementation of the traditional Chinese Chess (Xiangqi) game built with React Native.
          </Text>
          
          <Text style={styles.disclaimer}>
            Important Note: This project is for learning and research purposes only. The images and sound resources are from "Chinese Chess Wizard" (象棋小巫师), and the built-in engine is translated from xqlite (JS). Please do not use these resources for commercial projects.
          </Text>
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Features</Text>
          <View style={styles.featureList}>
            <Text style={styles.featureItem}>• Local gameplay with traditional Chinese Chess rules</Text>
            <Text style={styles.featureItem}>• Multiple game modes (AI opponent, local multiplayer, online multiplayer)</Text>
            <Text style={styles.featureItem}>• User authentication and profiles</Text>
            <Text style={styles.featureItem}>• Customizable skins for board and pieces</Text>
            <Text style={styles.featureItem}>• Game history and replay</Text>
            <Text style={styles.featureItem}>• Elo rating system for ranked matches</Text>
            <Text style={styles.featureItem}>• Tournament system</Text>
            <Text style={styles.featureItem}>• Multilingual support (English, Chinese, Vietnamese)</Text>
          </View>
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>References</Text>
          <TouchableOpacity onPress={() => Linking.openURL('https://www.xqbase.com/ecco/ecco_contents.htm#ecco_a')}>
            <Text style={styles.link}>• ECCO</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => Linking.openURL('https://www.xqbase.com/protocol/cchess_ucci.htm')}>
            <Text style={styles.link}>• UCCI</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => Linking.openURL('https://www.xqbase.com/protocol/cchess_move.htm')}>
            <Text style={styles.link}>• Move Notation</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => Linking.openURL('https://www.xqbase.com/protocol/cchess_fen.htm')}>
            <Text style={styles.link}>• FEN Format</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={() => Linking.openURL('https://www.xqbase.com/protocol/cchess_pgn.htm')}>
            <Text style={styles.link}>• PGN Format</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Acknowledgments</Text>
          <Text style={styles.paragraph}>
            • Chess engine based on xqlite
          </Text>
          <Text style={styles.paragraph}>
            • UI design inspired by "Chinese Chess Wizard" (象棋小巫师)
          </Text>
        </View>
        
        <View style={styles.footer}>
          <Text style={styles.footerText}>© 2024 Chinese Chess. All rights reserved.</Text>
          <Text style={styles.footerText}>Licensed under the MIT License</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 16,
  },
  section: {
    marginBottom: 24,
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  version: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    marginTop: 10,
    color: '#444',
  },
  paragraph: {
    fontSize: 16,
    color: '#555',
    lineHeight: 24,
    marginBottom: 10,
  },
  disclaimer: {
    fontSize: 14,
    color: '#777',
    fontStyle: 'italic',
    marginTop: 10,
    lineHeight: 20,
  },
  featureList: {
    marginTop: 5,
  },
  featureItem: {
    fontSize: 16,
    color: '#555',
    lineHeight: 24,
    marginBottom: 5,
  },
  link: {
    fontSize: 16,
    color: '#4a6ea9',
    lineHeight: 28,
    textDecorationLine: 'underline',
  },
  footer: {
    marginTop: 20,
    marginBottom: 40,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 14,
    color: '#888',
    lineHeight: 20,
  },
});

export default AboutScreen;
