import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:su_event/models/event_model.dart';

void main() {
  group('Event.fromFirestore Factory', () {

    test('Parses firebase documents', () async {
      final instance = FakeFirebaseFirestore();
      final eventData = {
        'title': 'Debug Party',
        'location': 'Everywhere',
        'category': 'Other',
        'time': '00:00',
        'date': '01/01/2026',
        'description': 'Enter the new year doing homework',
        'createdBy': 'user_123',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'imageUrls': ['http://fake.url.com', 'http://fake.image.com'],
      };

      await instance.collection('events').doc('test_id_1').set(eventData);
      final snapshot = await instance.collection('events').doc('test_id_1').get();
      final event = Event.fromFirestore(snapshot);

      expect(event.id, 'test_id_1');
      expect(event.title, 'Debug Party');
      expect(event.location, 'Everywhere');
      expect(event.imageUrls.length, 2);
      expect(event.imageUrls.first, 'http://fake.url.com');
      expect(event.createdAt, DateTime(2026, 1, 1));
    });

    test('Handles null and missing values', () async {
      final instance = FakeFirebaseFirestore();
      final partialData = {
        'title': 'Mystery Event',
        'createdAt': null,
      };

      await instance.collection('events').doc('test_id_2').set(partialData);
      final snapshot = await instance.collection('events').doc('test_id_2').get();
      final event = Event.fromFirestore(snapshot);

      expect(event.id, 'test_id_2');
      expect(event.title, 'Mystery Event');
      expect(event.location, '');
      expect(event.category, '');
      expect(event.description, '');
      expect(event.imageUrls, isEmpty);
      expect(event.createdAt, null);
    });
  });
}