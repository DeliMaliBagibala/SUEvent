import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  List<String> _savedEventIds = [];
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  List<String> get savedEventIds => _savedEventIds;

  AppAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _userData = null;
        _savedEventIds = [];
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userData = doc.data() as Map<String, dynamic>;
        _savedEventIds = List<String>.from(_userData?['savedEventIds'] ?? []);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register(String email, String password, String username) async {
    _setLoading(true);
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'username': username,
        'email': email,
        'bio': '',
        'profile_picture': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateProfile({String? username, String? bio, String? profilePicture}) async {
    if (_user == null) return;
    try {
      Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (profilePicture != null) updates['profile_picture'] = profilePicture;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updates);
        await _fetchUserData(); // Refresh local data
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  Future<void> toggleSavedEvent(String eventId) async {
    if (_user == null) return;

    final isSaved = _savedEventIds.contains(eventId);

    try {
      if (isSaved) {
        _savedEventIds.remove(eventId);
        await _firestore.collection('users').doc(_user!.uid).update({
          'savedEventIds': FieldValue.arrayRemove([eventId])
        });
      } else {
        _savedEventIds.add(eventId);
        await _firestore.collection('users').doc(_user!.uid).update({
          'savedEventIds': FieldValue.arrayUnion([eventId])
        });
      }
      notifyListeners();
    } catch (e) {
      print("Error toggling save: $e");
      if (isSaved) {
        _savedEventIds.add(eventId);
      } else {
        _savedEventIds.remove(eventId);
      }
      notifyListeners();
    }
  }



  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
