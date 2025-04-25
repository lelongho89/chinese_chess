import 'package:engine/engine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/game_manager.dart';
import 'models/game_setting.dart';
import 'models/locale_provider.dart';

/// 设置页
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GameSetting? setting;

  @override
  void initState() {
    super.initState();
    GameSetting.getInstance().then(
      (value) => setState(() {
        setting = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = 500;
    if (MediaQuery.of(context).size.width < width) {
      width = MediaQuery.of(context).size.width;
    }

    // Ensure the width is not too small
    width = width < 300 ? 300 : width;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingTitle),
        actions: [
          TextButton.icon(
            onPressed: () {
              setting?.save().then((v) {
                Navigator.pop(context);
                MyDialog.toast(context.l10n.saveSuccess, iconType: IconType.success);
              });
            },
            icon: const Icon(Icons.save),
            label: Text(context.l10n.save),
          ),
        ],
      ),
      body: Center(
        child: setting == null
            ? const CircularProgressIndicator()
            : Container(
                width: width,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.aiType,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<EngineInfo>(
                                segments: [
                                  ButtonSegment<EngineInfo>(
                                    value: builtInEngine,
                                    label: Text(context.l10n.builtInEngine),
                                  ),
                                  ...Engine().getSupportedEngines().map(
                                    (engine) => ButtonSegment<EngineInfo>(
                                      value: engine,
                                      label: Text(engine.name),
                                    ),
                                  ),
                                ],
                                selected: {setting!.info},
                                onSelectionChanged: (Set<EngineInfo> selected) {
                                  if (selected.isEmpty) return;
                                  setState(() {
                                    setting!.info = selected.first;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.aiLevel,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<int>(
                                segments: [
                                  ButtonSegment<int>(
                                    value: 10,
                                    label: Text(context.l10n.beginner),
                                  ),
                                  ButtonSegment<int>(
                                    value: 11,
                                    label: Text(context.l10n.intermediate),
                                  ),
                                  ButtonSegment<int>(
                                    value: 12,
                                    label: Text(context.l10n.master),
                                  ),
                                ],
                                selected: {setting!.engineLevel},
                                onSelectionChanged: (Set<int> selected) {
                                  if (selected.isEmpty) return;
                                  setState(() {
                                    setting!.engineLevel = selected.first;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: SwitchListTile(
                          title: Text(context.l10n.gameSound),
                          value: setting!.sound,
                          onChanged: (v) {
                            setState(() {
                              setting!.sound = v;
                            });
                          },
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.soundVolume,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Slider(
                                value: setting!.soundVolume,
                                min: 0,
                                max: 1,
                                divisions: 10,
                                label: (setting!.soundVolume * 100).toInt().toString(),
                                onChanged: (v) {
                                  setState(() {
                                    setting!.soundVolume = v;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.language,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment<String>(
                                    value: 'en',
                                    label: Text(context.l10n.languageEnglish),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'zh',
                                    label: Text(context.l10n.languageChinese),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'vi',
                                    label: Text(context.l10n.languageVietnamese),
                                  ),
                                ],
                                selected: {setting!.locale},
                                onSelectionChanged: (Set<String> selected) {
                                  if (selected.isEmpty) return;
                                  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                                  setState(() {
                                    setting!.locale = selected.first;
                                    // Update the locale provider
                                    localeProvider.setLocale(selected.first);
                                    // Save settings
                                    setting!.save().then((_) {
                                      print("Language saved: ${setting!.locale}");
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.chessSkin,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment<String>(
                                    value: 'woods',
                                    label: Text(context.l10n.skinWoods),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'stones',
                                    label: Text(context.l10n.skinStones),
                                  ),
                                ],
                                selected: {setting!.skin},
                                onSelectionChanged: (Set<String> selected) {
                                  if (selected.isEmpty) return;
                                  setState(() {
                                    setting!.skin = selected.first;
                                    // Update the skin in GameManager immediately
                                    GameManager.instance.updateSkin(selected.first);
                                    // Save settings
                                    setting!.save().then((_) {
                                      logger.info("Skin saved: ${setting!.skin}");
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
