import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chinese_chess/l10n/generated/app_localizations.dart';
import 'package:chinese_chess/widgets/rank_badge_widget.dart';
import 'package:chinese_chess/services/ranking_service.dart';

void main() {
  group('RankBadgeWidget Tests', () {
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

    testWidgets('should display rank badge with English localization', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 1200,
            showStars: true,
            showElo: true,
          ),
          locale: const Locale('en'),
        ),
      );

      // Should show "Apprentice" in English
      expect(find.text('Apprentice'), findsOneWidget);
      // Should show Chinese character
      expect(find.text('士'), findsOneWidget);
      // Should show ELO rating
      expect(find.text('1200 ELO'), findsOneWidget);
    });

    testWidgets('should display rank badge with Chinese localization', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 1200,
            showStars: true,
            showElo: true,
          ),
          locale: const Locale('zh', 'CN'),
        ),
      );

      // Should show Chinese character (appears twice - in badge and as display character)
      expect(find.text('士'), findsWidgets);
      // Should show ELO rating
      expect(find.text('1200 ELO'), findsOneWidget);
    });

    testWidgets('should display rank badge with Vietnamese localization', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 1200,
            showStars: true,
            showElo: true,
          ),
          locale: const Locale('vi'),
        ),
      );

      // Should show "Cố Vấn" in Vietnamese (appears twice - in badge and as display character)
      expect(find.text('Cố Vấn'), findsWidgets);
      // Should show ELO rating
      expect(find.text('1200 ELO'), findsOneWidget);
    });

    testWidgets('should display correct number of stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 1250, // Should be 3 stars in Apprentice rank
            showStars: true,
          ),
        ),
      );

      // Should show 3 filled stars
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });

    testWidgets('should display different ranks correctly', (WidgetTester tester) async {
      // Test General rank
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 2600, // General rank
            showStars: true,
          ),
        ),
      );

      expect(find.text('General'), findsOneWidget);
      expect(find.text('将'), findsOneWidget);

      // Test Soldier rank
      await tester.pumpWidget(
        createTestWidget(
          const RankBadgeWidget(
            eloRating: 500, // Soldier rank
            showStars: true,
          ),
        ),
      );

      expect(find.text('Soldier'), findsOneWidget);
      expect(find.text('兵'), findsOneWidget);
    });

    testWidgets('CompactRankBadge should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const CompactRankBadge(
            eloRating: 1200,
          ),
        ),
      );

      // Should show Chinese character
      expect(find.text('士'), findsOneWidget);
    });
  });

  group('RankingService Localization Tests', () {
    testWidgets('should provide correct localized names', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
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
          home: Builder(
            builder: (context) {
              final ranking = RankingService.getPlayerRanking(1200);

              return Scaffold(
                body: Column(
                  children: [
                    Text(ranking.rank.getLocalizedName(context)),
                    Text(ranking.rank.getLocalizedDescription(context)),
                    Text(ranking.rank.getDisplayCharacter(context)),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Apprentice'), findsOneWidget);
      expect(find.text('Players with basic rule understanding'), findsOneWidget);
      expect(find.text('士'), findsOneWidget);
    });
  });
}
