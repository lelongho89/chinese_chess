import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chinese_chess/models/game_setting.dart';
import 'package:chinese_chess/models/game_manager.dart';
import 'package:chinese_chess/models/chess_skin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GameManager updates skin correctly', () async {
    // Initialize GameSetting
    await GameSetting.getInstance();
    
    // Initialize GameManager
    final gameManager = GameManager.instance;
    await gameManager.init();
    
    // Get the initial skin
    final initialSkin = gameManager.skin.folder;
    
    // Change the skin
    final newSkin = initialSkin == 'woods' ? 'stones' : 'woods';
    gameManager.updateSkin(newSkin);
    
    // Verify that the skin has been updated
    expect(gameManager.skin.folder, equals(newSkin));
  });
}
