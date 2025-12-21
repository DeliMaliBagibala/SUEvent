import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'auth_provider.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppAuthProvider _authProvider;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider(this._authProvider) {
    if (_authProvider.isLoggedIn) {
      _subscribeToEvents();
    }
  }

  // Real-time updates using Stream
  void _subscribeToEvents() {
    _setLoading(true);
    _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      _setLoading(false);
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    });
  }

  Future<void> addEvent(Event event) async {
    if (!_authProvider.isLoggedIn) return;
    try {
      await _firestore.collection('events').add({
        ...event.toMap(),
        'createdBy': _authProvider.user!.uid, // Ensure createdBy is set
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEvent(Event event) async {
    if (!_authProvider.isLoggedIn) return;
    // Check if user is the creator (optional strict rule, though Firestore rules handle security)
    if (event.createdBy != _authProvider.user!.uid) {
        _error = "You can only edit your own events.";
        notifyListeners();
        return;
    }

    try {
      await _firestore.collection('events').doc(event.id).update(event.toMap());
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId, String createdBy) async {
    if (!_authProvider.isLoggedIn) return;
     if (createdBy != _authProvider.user!.uid) {
        _error = "You can only delete your own events.";
        notifyListeners();
        return;
    }

    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // Method to clear error message
  void clearError() {
      _error = null;
      notifyListeners();
  }
}
