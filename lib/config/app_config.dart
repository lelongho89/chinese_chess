import 'package:flutter/foundation.dart';

/// Application configuration class for managing environment-specific settings
class AppConfig {
  // Private constructor for singleton pattern
  AppConfig._();
  
  /// Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;

  // ============================================================================
  // MATCHMAKING CONFIGURATION
  // ============================================================================

  /// Default time control base time in seconds (5 minutes)
  static const int _defaultBaseTime = 300; // 5 minutes

  /// Default time increment in seconds (+3 seconds)
  static const int _defaultIncrement = 3; // +3 seconds

  /// Standard time control (5+3)
  static const String _defaultTimeControl = '5+3';

  /// Match confirmation timeout in seconds
  static const int _confirmationTimeout = 10;

  /// Get the configured base time for matches
  int get matchTimeControl {
    const envTimeControl = String.fromEnvironment('MATCH_TIME_CONTROL');
    if (envTimeControl.isNotEmpty) {
      final parsed = int.tryParse(envTimeControl);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return _defaultBaseTime;
  }

  /// Get the configured increment time in seconds
  int get incrementSeconds {
    const envIncrement = String.fromEnvironment('INCREMENT_SECONDS');
    if (envIncrement.isNotEmpty) {
      final parsed = int.tryParse(envIncrement);
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
    }
    return _defaultIncrement;
  }

  /// Get confirmation timeout in seconds
  int get confirmationTimeout => _confirmationTimeout;

  /// Get formatted time control string for display
  String get matchTimeControlFormatted {
    final minutes = matchTimeControl ~/ 60;
    final inc = incrementSeconds;
    // Always show as "5+3" format for consistency
    return '$minutes+$inc';
  }

  // ============================================================================
  // MATCHMAKING BEHAVIOR CONFIGURATION
  // ============================================================================

  /// Whether to enable AI matching when no human opponents are found
  /// Can be configured via environment variable ENABLE_AI_MATCHING
  /// Default: true
  bool get enableAIMatching {
    const envValue = String.fromEnvironment('ENABLE_AI_MATCHING');
    if (envValue.isNotEmpty) {
      return envValue.toLowerCase() == 'true';
    }
    return true; // Default enabled
  }

  /// Time to wait before spawning AI opponent (in seconds)
  /// Can be configured via environment variable AI_SPAWN_DELAY
  /// Default: 10 seconds
  int get aiSpawnDelaySeconds {
    const envValue = String.fromEnvironment('AI_SPAWN_DELAY');
    if (envValue.isNotEmpty) {
      final parsed = int.tryParse(envValue);
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
    }
    return 10; // Default 10 seconds
  }

  /// Maximum Elo difference for matchmaking
  /// Can be configured via environment variable MAX_ELO_DIFFERENCE
  /// Default: 200
  int get maxEloDifference {
    const envValue = String.fromEnvironment('MAX_ELO_DIFFERENCE');
    if (envValue.isNotEmpty) {
      final parsed = int.tryParse(envValue);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return 200; // Default 200 Elo points
  }

  /// Queue timeout duration (how long to wait before expiring queue entry)
  /// Can be configured via environment variable QUEUE_TIMEOUT_MINUTES
  /// Default: 10 minutes
  Duration get queueTimeout {
    const envValue = String.fromEnvironment('QUEUE_TIMEOUT_MINUTES');
    if (envValue.isNotEmpty) {
      final parsed = int.tryParse(envValue);
      if (parsed != null && parsed > 0) {
        return Duration(minutes: parsed);
      }
    }
    return const Duration(minutes: 10); // Default 10 minutes
  }

  // ============================================================================
  // GAME CONFIGURATION
  // ============================================================================

  /// Whether to enforce side alternation for fair play
  /// Can be configured via environment variable ENFORCE_SIDE_ALTERNATION
  /// Default: true
  bool get enforceSideAlternation {
    const envValue = String.fromEnvironment('ENFORCE_SIDE_ALTERNATION');
    if (envValue.isNotEmpty) {
      return envValue.toLowerCase() == 'true';
    }
    return true; // Default enabled
  }

  /// Whether games are ranked by default
  /// Can be configured via environment variable DEFAULT_RANKED_GAMES
  /// Default: true
  bool get defaultRankedGames {
    const envValue = String.fromEnvironment('DEFAULT_RANKED_GAMES');
    if (envValue.isNotEmpty) {
      return envValue.toLowerCase() == 'true';
    }
    return true; // Default ranked
  }

  // ============================================================================
  // DEBUG AND TESTING CONFIGURATION
  // ============================================================================

  /// Whether to show debug tools in matchmaking screen
  /// Can be configured via environment variable SHOW_DEBUG_TOOLS
  /// Default: true in debug mode, false in release mode
  bool get showDebugTools {
    const envValue = String.fromEnvironment('SHOW_DEBUG_TOOLS');
    if (envValue.isNotEmpty) {
      return envValue.toLowerCase() == 'true';
    }
    return kDebugMode; // Default based on build mode
  }

  /// Number of AI users to create for testing
  /// Can be configured via environment variable TEST_AI_USER_COUNT
  /// Default: 15
  int get testAIUserCount {
    const envValue = String.fromEnvironment('TEST_AI_USER_COUNT');
    if (envValue.isNotEmpty) {
      final parsed = int.tryParse(envValue);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return 15; // Default 15 AI users
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get all configuration values as a map for debugging
  Map<String, dynamic> toMap() {
    return {
      'matchTimeControl': matchTimeControl,
      'matchTimeControlFormatted': matchTimeControlFormatted,
      'enableAIMatching': enableAIMatching,
      'aiSpawnDelaySeconds': aiSpawnDelaySeconds,
      'maxEloDifference': maxEloDifference,
      'queueTimeoutMinutes': queueTimeout.inMinutes,
      'enforceSideAlternation': enforceSideAlternation,
      'defaultRankedGames': defaultRankedGames,
      'showDebugTools': showDebugTools,
      'testAIUserCount': testAIUserCount,
    };
  }

  /// Print configuration for debugging
  void printConfig() {
    if (kDebugMode) {
      print('=== App Configuration ===');
      toMap().forEach((key, value) {
        print('$key: $value');
      });
      print('========================');
    }
  }

  // ============================================================================
  // ENVIRONMENT SWITCHING HELPERS
  // ============================================================================

  /// We now use a single time control: 5+3
  /// These constants are kept for backward compatibility but are deprecated
  @Deprecated('Use AppConfig.instance.matchTimeControl instead')
  static const int timeControl10Minutes = 600;
  @Deprecated('Use AppConfig.instance.matchTimeControl instead')
  static const int timeControl5Minutes = 300;
  @Deprecated('Use AppConfig.instance.matchTimeControl instead')
  static const int timeControl3Minutes = 180;

  /// Get available time control options for admin configuration
  @Deprecated('Single time control is now used')
  static List<int> get availableTimeControls => [_defaultBaseTime];

  /// Get formatted names for time control options
  @Deprecated('Single time control is now used')
  static Map<int, String> get timeControlNames => {
    _defaultBaseTime: _defaultTimeControl,
  };
}

/// Extension for easy access to app config
extension AppConfigExtension on AppConfig {
  /// Quick access to formatted time control for UI display
  String get timeDisplayText => matchTimeControlFormatted;
  
  /// Quick access to check if in simplified mode (single time control)
  bool get isSimplifiedMode => true; // Always true in this simplified version
}
