import 'package:engine/engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
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
          TextButton(
            onPressed: () {
              setting?.save().then((v) {
                Navigator.pop(context);
                MyDialog.toast(context.l10n.saveSuccess, iconType: IconType.success);
              });
            },
            child: Text(
              context.l10n.save,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: setting == null
            ? const CircularProgressIndicator()
            : Container(
                width: width,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      ListTile(
                        title: Text(context.l10n.aiType),
                        trailing: SizedBox(
                          width: width * 0.6,
                          child: CupertinoSegmentedControl(
                            onValueChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                setting!.info = value as EngineInfo;
                              });
                            },
                            groupValue: setting!.info,
                            children: {
                              builtInEngine: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.builtInEngine),
                              ),
                              for (var engine in Engine().getSupportedEngines())
                                engine: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(engine.name),
                                ),
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(context.l10n.aiLevel),
                        trailing: SizedBox(
                          width: width * 0.6,
                          child: CupertinoSegmentedControl(
                            onValueChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                setting!.engineLevel = value as int;
                              });
                            },
                            groupValue: setting!.engineLevel,
                            children: {
                              10: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.beginner),
                              ),
                              11: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.intermediate),
                              ),
                              12: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.master),
                              ),
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(context.l10n.gameSound),
                        trailing: CupertinoSwitch(
                          value: setting!.sound,
                          onChanged: (v) {
                            setState(() {
                              setting!.sound = v;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(context.l10n.soundVolume),
                        trailing: SizedBox(
                          width: width * 0.5,
                          child: CupertinoSlider(
                            value: setting!.soundVolume,
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              setState(() {
                                setting!.soundVolume = v;
                              });
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(context.l10n.language),
                        trailing: SizedBox(
                          width: width * 0.6,
                          child: CupertinoSegmentedControl(
                            onValueChanged: (value) {
                              if (value == null) return;
                              final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                              setState(() {
                                setting!.locale = value as String;
                                // Update the locale provider
                                localeProvider.setLocale(value);
                                // Save settings
                                setting!.save().then((_) {
                                  print("Language saved: ${setting!.locale}");
                                });
                              });
                            },
                            groupValue: setting!.locale,
                            children: {
                              'en': Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.languageEnglish),
                              ),
                              'zh': Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.languageChinese),
                              ),
                              'vi': Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(context.l10n.languageVietnamese),
                              ),
                            },
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
