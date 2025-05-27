import 'dart:convert';

import 'package:engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global.dart';
import 'game_manager.dart';

const builtInEngine = EngineInfo(name: 'builtIn', data: '');

class GameSetting {
  static SharedPreferences? storage;
  static GameSetting? _instance;
  static const cacheKey = 'setting';
  static Function? onSettingsChanged;

  EngineInfo info = builtInEngine;
  int engineLevel = 10;
  bool sound = true;
  double soundVolume = 1;
  String locale = 'en';
  String skin = 'woods';
  int difficulty = 0; // 0: Easy, 1: Medium, 2: Hard

  GameSetting({
    this.info = builtInEngine,
    this.engineLevel = 10,
    this.sound = true,
    this.soundVolume = 1,
    this.locale = 'en',
    this.skin = 'woods',
    this.difficulty = 0,
  });

  GameSetting.fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return;
    Map<String, dynamic> json = jsonDecode(jsonStr);
    if (json.containsKey('engine_info')) {
      info = Engine().getSupportedEngines().firstWhere(
            (e) => e.name == json['engine_info'],
            orElse: () => builtInEngine,
          );
    }
    if (json.containsKey('engine_level')) {
      engineLevel = json['engine_level'];
      if (engineLevel < 10 || engineLevel > 12) {
        engineLevel = 10;
      }
    }
    if (json.containsKey('sound')) {
      sound = json['sound'];
    }
    if (json.containsKey('sound_volume')) {
      soundVolume = json['sound_volume'];
    }
    if (json.containsKey('locale')) {
      locale = json['locale'];
    }
    if (json.containsKey('skin')) {
      skin = json['skin'];
    }
    if (json.containsKey('difficulty')) {
      difficulty = json['difficulty'];
      if (difficulty < 0 || difficulty > 2) {
        difficulty = 0;
      }
    }
  }

  static Future<GameSetting> getInstance() async {
    _instance ??= await GameSetting.init();
    return _instance!;
  }

  static GameSetting? get instance => _instance;

  static Future<GameSetting> init() async {
    try {
      storage ??= await SharedPreferences.getInstance();
    } catch (e) {
      logger.warning(e);
    }
    String? json = storage?.getString(cacheKey);

    // Set up the onSettingsChanged callback to update the skin in GameManager
    // We'll set this after GameManager is initialized to avoid circular dependency
    if (onSettingsChanged == null) {
      Future.delayed(Duration.zero, () {
        onSettingsChanged = () {
          if (_instance != null) {
            logger.info("Settings changed, updating skin to: ${_instance!.skin}");
            // Only update if GameManager is already initialized
            if (GameManager.instance.skin.folder != _instance!.skin) {
              GameManager.instance.updateSkin(_instance!.skin);
            }
          }
        };
      });
    }

    return GameSetting.fromJson(json);
  }

  Future<bool> save() async {
    storage ??= await SharedPreferences.getInstance();
    await storage?.setString(cacheKey, toString());
    print("Settings saved: $this");
    if (onSettingsChanged != null) {
      onSettingsChanged!();
    }
    return true;
  }

  @override
  String toString() => jsonEncode({
        'engine_info': info.name,
        'engine_level': engineLevel,
        'sound': sound,
        'sound_volume': soundVolume,
        'locale': locale,
        'skin': skin,
        'difficulty': difficulty,
      });
}
