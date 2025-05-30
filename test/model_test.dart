// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:logging/logging.dart';

void main() {
  final logger = Logger.root;
  logger.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('test Future', () async {
    logger.info(DateTime.now().millisecondsSinceEpoch);
    await Future.delayed(const Duration(seconds: 5));
    logger.info(DateTime.now().millisecondsSinceEpoch);

    Future.delayed(const Duration(seconds: 5)).then((value) {
      logger.info(DateTime.now().millisecondsSinceEpoch);
    });
  });
}
