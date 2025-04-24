import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'game_setting.dart';

class Sound {
  static const move = 'move2.wav';
  static const capture = 'capture2.wav';
  static const check = 'check2.wav';
  static const click = 'click.wav';
  static const newGame = 'newgame.wav';
  static const loose = 'loss.wav';
  static const win = 'win.wav';
  static const draw = 'draw.wav';
  static const illegal = 'illegal.wav';

  // Updated for audioplayers 6.4.0
  static final AudioPlayer audioPlayer = AudioPlayer();
  static final AudioCache audioCache = AudioCache(prefix: 'assets/sounds/');

  static GameSetting? setting;

  static Future<bool> play(String id) async {
    setting ??= await GameSetting.getInstance();
    if (!setting!.sound) return false;

    // Updated for audioplayers 6.4.0
    final source = AssetSource(id);
    await audioPlayer.setVolume(setting!.soundVolume);
    await audioPlayer.play(source);

    return true;
  }

  // static final Map<String, Completer<int>> _loaders = {};
  // static Future<int> loadAsset(String id) async {
  //   if (_loaders.containsKey(id)) {
  //     return _loaders[id]!.future;
  //   }
  //   _loaders[id] = Completer<int>();
  //   rootBundle.load("assets/sounds/$id").then((value) {
  //     _loaders[id]!.complete(pool.load(value));
  //   });

  //   return _loaders[id]!.future;
  // }
}
