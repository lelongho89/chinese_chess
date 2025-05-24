import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../game_board.dart';
import '../setting.dart';

import '../models/game_setting.dart';
import '../models/play_mode.dart';
import 'profile_screen.dart';
import 'new_game_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: context.l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: context.l10n.settings,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSetting? setting;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final gameSetting = await GameSetting.getInstance();
    setState(() {
      setting = gameSetting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          context.l10n.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Single Player (AI) Mode
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _startGame(PlayMode.modeRobot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.smart_toy, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.singlePlayer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Local Multiplayer Mode - Hidden for MVP
            // SizedBox(
            //   width: double.infinity,
            //   height: 60,
            //   child: ElevatedButton(
            //     onPressed: () => _startGame(PlayMode.modeFree),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Theme.of(context).colorScheme.secondary,
            //       foregroundColor: Theme.of(context).colorScheme.onSecondary,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(16),
            //       ),
            //       elevation: 0,
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         const Icon(Icons.people, size: 24),
            //         const SizedBox(width: 12),
            //         Text(
            //           context.l10n.localMultiplayer,
            //           style: const TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 16),

            // Online Multiplayer Mode (Coming Soon)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: null, // Disabled for now
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.onlineMultiplayer,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          context.l10n.comingSoon,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _startGame(PlayMode mode) async {
    // Load settings to get difficulty
    final gameSetting = setting ?? await GameSetting.getInstance();

    // Apply the game mode and difficulty settings
    if (mode == PlayMode.modeRobot) {
      // Set the engine level based on difficulty from settings
      final engineLevel = 10 + gameSetting.difficulty;
      // TODO: Apply engine level to GameManager
      print('Starting Single Player game with difficulty: ${gameSetting.difficulty} (engine level: $engineLevel)');
    } else if (mode == PlayMode.modeFree) {
      print('Starting Local Multiplayer game');
    }

    // Navigate to game board with the selected mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameBoard(initialMode: mode),
      ),
    );
  }
}