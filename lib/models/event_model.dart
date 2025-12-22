import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String category;
  final String time;
  final String date;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final List<String> imageUrls;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.time,
    required this.date,
    required this.description,
    required this.createdBy,
    this.createdAt,
    this.imageUrls = const [],
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      time: data['time'] ?? '',
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      imageUrls: (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'category': category,
      'time': time,
      'date': date,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'imageUrls': imageUrls,
    };
  }
}
