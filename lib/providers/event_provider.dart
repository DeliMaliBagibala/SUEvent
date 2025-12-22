import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/comment_model.dart';
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
        'createdBy': _authProvider.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEvent(Event event) async {
    if (!_authProvider.isLoggedIn) return;
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

  Stream<List<Comment>> getCommentsStream(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  Future<void> addComment(String eventId, String text) async {
    if (!_authProvider.isLoggedIn || _authProvider.user == null) return;

    try {
      final username = _authProvider.userData?['username'] ?? 'User';

      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .add({
        'text': text,
        'userId': _authProvider.user!.uid,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }




  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
      _error = null;
      notifyListeners();
  }
}


