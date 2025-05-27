import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chinese_chess/l10n/generated/app_localizations.dart';
import 'package:chinese_chess/global.dart';

void main() {
  group('Profile Screen Stats Tests', () {
    Widget createTestWidget(Widget child, {Locale locale = const Locale('en')}) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('zh', 'CN'),
          Locale('vi'),
        ],
        home: Scaffold(body: child),
      );
    }

    testWidgets('should display ELO Rating instead of Games Played', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  Text(context.l10n.eloRating),
                  Text(context.l10n.gamesWon),
                  Text(context.l10n.gamesLost),
                ],
              );
            },
          ),
        ),
      );

      // Should show ELO Rating
      expect(find.text('ELO Rating'), findsOneWidget);
      // Should show Games Won
      expect(find.text('Games Won'), findsOneWidget);
      // Should show Games Lost
      expect(find.text('Games Lost'), findsOneWidget);
      // Should NOT show Games Played
      expect(find.text('Games Played'), findsNothing);
    });

    testWidgets('should display ELO Rating in Chinese', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  Text(context.l10n.eloRating),
                  Text(context.l10n.gamesWon),
                  Text(context.l10n.gamesLost),
                ],
              );
            },
          ),
          locale: const Locale('zh', 'CN'),
        ),
      );

      // Should show ELO Rating in Chinese
      expect(find.text('ELO等级分'), findsOneWidget);
      // Should show Games Won in Chinese
      expect(find.text('获胜游戏'), findsOneWidget);
      // Should show Games Lost in Chinese
      expect(find.text('失败游戏'), findsOneWidget);
    });

    testWidgets('should display ELO Rating in Vietnamese', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  Text(context.l10n.eloRating),
                  Text(context.l10n.gamesWon),
                  Text(context.l10n.gamesLost),
                ],
              );
            },
          ),
          locale: const Locale('vi'),
        ),
      );

      // Should show ELO Rating in Vietnamese
      expect(find.text('Điểm ELO'), findsOneWidget);
      // Should show Games Won in Vietnamese
      expect(find.text('Số Ván Thắng'), findsOneWidget);
      // Should show Games Lost in Vietnamese
      expect(find.text('Số Ván Thua'), findsOneWidget);
    });
  });
}
