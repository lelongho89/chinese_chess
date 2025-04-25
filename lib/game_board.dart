import 'dart:async';
import 'dart:io';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'global.dart';
import 'setting.dart';
import 'components/game_bottom_bar.dart';
import 'models/play_mode.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'components/play.dart';
import 'components/edit_fen.dart';

/// 游戏页面
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

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
    Future.delayed(Duration.zero).then((value) => gamer.init());
  }

  Widget selectMode() {
    final maxHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SizedBox(
        height: maxHeight * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mode = PlayMode.modeRobot;
                });
              },
              icon: const Icon(Icons.android),
              label: Text(context.l10n.modeRobot),
            ),
            ElevatedButton.icon(
              onPressed: () {
                MyDialog.toast(
                  context.l10n.featureNotAvailable,
                  iconType: IconType.error,
                );
              },
              icon: const Icon(Icons.wifi),
              label: Text(context.l10n.modeOnline),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mode = PlayMode.modeFree;
                });
              },
              icon: const Icon(Icons.map),
              label: Text(context.l10n.modeFree),
            ),

          ],
        ),
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
      // Updated for file_picker 6.1.1
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pgn', 'PGN'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          String content = gbk.decode(file.bytes!);
          if (gamer.isStop) {
            gamer.newGame();
          }
          gamer.loadPGN(content);
        } else if (file.path != null) {
          // Handle file path if bytes are not available
          final fileData = await File(file.path!).readAsBytes();
          String content = gbk.decode(fileData);
          if (gamer.isStop) {
            gamer.newGame();
          }
          gamer.loadPGN(content);
        }
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
