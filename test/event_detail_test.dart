import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:su_event/event_detail.dart';
import 'package:su_event/models/event_model.dart';
import 'package:su_event/models/comment_model.dart';
import 'package:su_event/providers/auth_provider.dart';
import 'package:su_event/providers/event_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Set up mock data and providers
class MockAuthProvider extends ChangeNotifier implements AppAuthProvider {
  @override
  User? get user => null;

  @override
  Map<String, dynamic>? get userData => {
    'username': 'Test User',
    'email': 'test@sabanciuniv.edu',
    'bio': 'Test bio',
    'profile_picture': '',
    'savedEvents': [],
  };

  @override
  bool get isLoading => false;
  @override
  bool get isLoggedIn => true;
  @override
  List<String> get savedEventIds => [];
  @override
  Future<String?> login(String email, String password) async => null;
  @override
  Future<String?> register(String email, String password, String username) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<void> updateProfile({String? username, String? bio, String? profilePicture}) async {}
  @override
  Future<Map<String, dynamic>?> getUserById(String uid) async => null;
  @override
  Future<void> toggleSavedEvent(String eventId) async {}
  @override
  Future<String?> changePassword(String newPassword) async => null;
}

class MockEventProvider extends ChangeNotifier implements EventProvider {
  @override
  List<Event> get events => [];
  @override
  bool get isLoading => false;
  @override
  String? get error => null;
  @override
  Future<void> addEvent(Event event) async {}
  @override
  Future<void> updateEvent(Event event) async {}
  @override
  Future<void> deleteEvent(String eventId, String createdBy) async {}
  @override
  Stream<List<Comment>> getCommentsStream(String eventId) {
    return Stream.value([]);
  }
  @override
  Future<void> addComment(String eventId, String text) async {}
  @override
  void clearError() {}
}

void main() {
  testWidgets('EventDetailScreen test for rendering the event and comment section',
          (WidgetTester tester) async {
        final testEvent = Event(
          id: '310',
          title: 'Debug Party',
          date: '01/01/2026',
          time: '00:00',
          category: 'Other',
          description: 'Enter the new year doing homework',
          location: 'Everywhere',
          createdBy: 'test_creator',
          imageUrls: [],
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppAuthProvider>(
                create: (_) => MockAuthProvider(),),
              ChangeNotifierProvider<EventProvider>(create: (_) => MockEventProvider(),),
            ],
            child: MaterialApp(
              home: EventDetailScreen(
                event: testEvent,
                onBackTap: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify event details are displayed
        expect(find.text('DEBUG PARTY'), findsOneWidget);
        expect(find.text('Everywhere'), findsOneWidget);
        expect(find.text('00:00'), findsOneWidget);
        expect(find.text('Enter the new year doing homework'), findsOneWidget);

        // Verify empty comment state
        expect(find.text("No comments yet. Be the first!"), findsOneWidget);
      });

  testWidgets('EventDetailScreen displays action buttons',
          (WidgetTester tester) async {
        final testEvent = Event(
          id: '311',
          title: 'Test Event',
          date: '01/01/2026',
          time: '12:00',
          category: 'Sports',
          description: 'Test description',
          location: 'Test Location',
          createdBy: 'test_creator',
          imageUrls: [],
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppAuthProvider>(create: (_) => MockAuthProvider(),),
              ChangeNotifierProvider<EventProvider>(create: (_) => MockEventProvider(),),
            ],
            child: MaterialApp(
              home: EventDetailScreen(
                event: testEvent,
                onBackTap: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify action buttons are present
        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });

  testWidgets('EventDetailScreen back button works',
          (WidgetTester tester) async {
        bool backTapped = false;

        final testEvent = Event(
          id: '312',
          title: 'Test Event',
          date: '01/01/2026',
          time: '12:00',
          category: 'Sports',
          description: 'Test description',
          location: 'Test Location',
          createdBy: 'test_creator',
          imageUrls: [],
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppAuthProvider>(create: (_) => MockAuthProvider(),),
              ChangeNotifierProvider<EventProvider>(create: (_) => MockEventProvider(),),],
            child: MaterialApp(
              home: EventDetailScreen(
                event: testEvent,
                onBackTap: () {
                  backTapped = true;},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // Find the back button
        final backButton = find.byIcon(Icons.arrow_left);
        expect(backButton, findsWidgets);

        // Tap the back button in the header
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();

      });
}