import 'dart:async';
import 'dart:io';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'global.dart';
import 'setting.dart';
import 'components/game_bottom_bar.dart';
import 'models/play_mode.dart';
import 'models/supabase_auth_service.dart';
import 'screens/matchmaking_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'components/play.dart';
import 'components/edit_fen.dart';
import 'services/match_invitation_handler.dart';

/// 游戏页面
class GameBoard extends StatefulWidget {
  final PlayMode? initialMode;

  const GameBoard({super.key, this.initialMode});

  @override
  State<GameBoard> createState() => GameBoardState();
}

// Make the state class public so it can be accessed from other files
class GameBoardState extends State<GameBoard> {
  GameManager gamer = GameManager.instance;
  PlayMode? mode;

  @override
  void initState() {
    super.initState();
    print('GameBoard: initState called');
    // Set the initial mode if provided
    mode = widget.initialMode;
    // GameManager will initialize itself when needed
  }

  Widget selectMode() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header Section
          const SizedBox(height: 32),
          Text(
            context.l10n.appTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.chooseGameMode,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Game Mode Cards
          Expanded(
            child: ListView(
              children: [
                _buildGameModeCard(
                  icon: Icons.smart_toy,
                  title: context.l10n.modeRobot,
                  subtitle: context.l10n.modeRobotSubtitle,
                  onTap: () {
                    setState(() {
                      mode = PlayMode.modeRobot;
                    });
                  },
                  isEnabled: true,
                ),
                const SizedBox(height: 16),
                _buildGameModeCard(
                  icon: Icons.wifi,
                  title: context.l10n.modeOnline,
                  subtitle: context.l10n.modeOnlineSubtitle,
                  onTap: () {
                    _navigateToOnlineMode();
                  },
                  isEnabled: true,
                ),
                // Free Mode - Hidden for MVP
                // const SizedBox(height: 16),
                // _buildGameModeCard(
                //   icon: Icons.people,
                //   title: context.l10n.modeFree,
                //   subtitle: context.l10n.modeFreeSubtitle,
                //   onTap: () {
                //     setState(() {
                //       mode = PlayMode.modeFree;
                //     });
                //   },
                //   isEnabled: true,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isEnabled ? 2 : 1,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isEnabled
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isEnabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isEnabled
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.comingSoon,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to online mode (matchmaking)
  void _navigateToOnlineMode() {
    // Check if user is authenticated
    final authService = Provider.of<SupabaseAuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      // Show login dialog or navigate to login screen
      MyDialog.alert('Please login first to play online');
      return;
    }

    // Navigate to matchmaking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchmakingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              tooltip: context.l10n.openMenu,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: mode == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  tooltip: context.l10n.flipBoard,
                  onPressed: () {
                    gamer.flip();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: context.l10n.copyCode,
                  onPressed: () {
                    copyFen();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.airplay),
                  tooltip: context.l10n.parseCode,
                  onPressed: () {
                    applyFen();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.airplay),
                  tooltip: context.l10n.editCode,
                  onPressed: () {
                    editFen();
                  },
                ),
                /*IconButton(icon: Icon(Icons.minimize), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.zoom_out_map), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.clear), color: Colors.red, onPressed: (){
            this._showDialog(context.l10n.exit_now,
                [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text(context.l10n.dont_exit),
                  ),
                  TextButton(
                      onPressed: (){
                        if(!kIsWeb){
                          Isolate.current.pause();
                          exit(0);
                        }
                      },
                      child: Text(context.l10n.yes_exit,style: TextStyle(color:Colors.red)),
                  )
                ]
            );
          })*/
              ],
      ),
      drawer: Drawer(
        semanticLabel: context.l10n.menu,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    Text(
                      context.l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(context.l10n.newGame),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (mode == null) {
                    setState(() {
                      mode = PlayMode.modeFree;
                    });
                  }
                  gamer.newGame();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(context.l10n.loadManual),
              onTap: () {
                Navigator.pop(context);
                if (mode == null) {
                  setState(() {
                    mode = PlayMode.modeFree;
                  });
                }
                loadFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(context.l10n.saveManual),
              onTap: () {
                Navigator.pop(context);
                saveManual();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(context.l10n.copyCode),
              onTap: () {
                Navigator.pop(context);
                copyFen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(context.l10n.scanQRCode),
              onTap: () {
                Navigator.pop(context);
                MatchInvitationHandler.instance.showQRScanner(context);
              },
            ),
            // Profile option - only show if user is authenticated
            Consumer<SupabaseAuthService>(
              builder: (context, authService, _) {
                if (authService.isAuthenticated) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(context.l10n.profile),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const ProfileScreen(),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(context.l10n.setting),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SettingPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: mode == null ? selectMode() : PlayPage(mode: mode!),
        ),
      ),
      bottomNavigationBar:
          (mode == null || MediaQuery.of(context).size.width >= 980)
              ? null
              : GameBottomBar(mode!),
    );
  }

  void editFen() {
    Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return GameWrapper(child: EditFen(fen: gamer.fenStr));
        },
      ),
    ).then((fenStr) {
      if (fenStr != null && fenStr.isNotEmpty) {
        gamer.newGame(fen: fenStr);
      }
    });
  }

  Future<void> applyFen() async {
    final l10n = context.l10n;
    ClipboardData? cData = await Clipboard.getData(Clipboard.kTextPlain);
    String fenStr = cData?.text ?? '';
    TextEditingController filenameController =
        TextEditingController(text: fenStr);
    filenameController.addListener(() {
      fenStr = filenameController.text;
    });

    final confirmed = await MyDialog.confirm(
      TextField(
        controller: filenameController,
      ),
      buttonText: l10n.apply,
      title: l10n.situationCode,
    );
    if (confirmed ?? false) {
      if (RegExp(
        r'^[abcnrkpABCNRKP\d]{1,9}(?:/[abcnrkpABCNRKP\d]{1,9}){9}(\s[wb]\s-\s-\s\d+\s\d+)?$',
      ).hasMatch(fenStr)) {
        gamer.newGame(fen: fenStr);
      } else {
        MyDialog.alert(l10n.invalidCode);
      }
    }
  }

  void copyFen() {
    Clipboard.setData(ClipboardData(text: gamer.fenStr));
    MyDialog.alert(context.l10n.copySuccess);
  }

  Future<void> saveManual() async {
    String content = gamer.manual.export();
    String filename = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}.pgn';
    if (Platform.isAndroid || Platform.isIOS) {
      await _saveManualNative(content, filename);
    }
  }

  Future<void> _saveManualNative(String content, String filename) async {
    try {
      // For iOS, we'll use the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';

      List<int> fData = gbk.encode(content);
      await File(path).writeAsBytes(fData);

      if (context.mounted) {
        MyDialog.toast('${context.l10n.saveSuccess}: $path');
      }
    } catch (e) {
      if (context.mounted) {
        MyDialog.alert('Error saving file: $e');
      }
    }
  }

  Future<void> loadFile() async {
    try {
      // Use flutter_document_picker instead of file_picker
      final filePath = await FlutterDocumentPicker.openDocument(
        params: FlutterDocumentPickerParams(
          allowedFileExtensions: ['pgn', 'PGN'],
          allowedMimeTypes: ['application/octet-stream'],
        ),
      );

      if (filePath != null) {
        // Read the file data
        final fileData = await File(filePath).readAsBytes();
        String content = gbk.decode(fileData);

        if (gamer.isStop) {
          gamer.newGame();
        }
        gamer.loadPGN(content);
      } else {
        // User canceled the picker
      }
    } catch (e) {
      if (context.mounted) {
        MyDialog.alert('Error loading file: $e');
      }
    }
  }
}
