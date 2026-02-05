import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/profile/presentation/views/movie_diary_view.dart';
import 'package:movies_app/profile/presentation/views/event_view.dart';
import 'package:movies_app/profile/presentation/views/faq_contact_view.dart';

void main() {
  group('Profile Features Tests', () {
    testWidgets('Movie Diary View renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDiaryView(),
        ),
      );

      // Verify AppBar title
      expect(find.text('Movie Diary'), findsOneWidget);
      
      // Verify statistics cards are present
      expect(find.text('Total Movies Watched'), findsOneWidget);
      expect(find.text('Total Minutes Watched'), findsOneWidget);
      expect(find.text('Most Watched Genre'), findsOneWidget);
    });

    testWidgets('Event View renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EventView(),
        ),
      );

      // Verify AppBar title
      expect(find.text('Event Seru'), findsOneWidget);
      
      // Verify at least one event card is present
      expect(find.text('VIEW DETAIL'), findsWidgets);
    });

    testWidgets('FAQ Contact View renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FaqContactView(),
        ),
      );

      // Verify AppBar title
      expect(find.text('FAQ & Contact Us'), findsOneWidget);
      
      // Verify FAQ section is present
      expect(find.text('Browse by FAQ Category'), findsOneWidget);
      
      // Verify quick contact buttons
      expect(find.text('Lost & Found'), findsOneWidget);
      expect(find.text('Membership'), findsOneWidget);
    });
  });
}

