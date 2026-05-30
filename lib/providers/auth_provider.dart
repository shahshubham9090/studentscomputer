import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/error_handler.dart';
import '../core/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _authError;
  String? get authError => _authError;

  bool _isSigningUp = false;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    if (_authError == error) return;
    _authError = error;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    // Prevent listener from interfering during explicit signup flow
    if (_isSigningUp) {
      debugPrint("AuthProvider: Skipping listener during signup.");
      return;
    }

    debugPrint("AuthProvider: Auth State Changed. User: ${firebaseUser?.uid}");
    
    _setLoading(true);
    _setError(null);

    try {
      if (firebaseUser == null) {
        _currentUser = null;
      } else {
        await _fetchUserDetails(firebaseUser.uid);
      }
    } catch (e) {
      debugPrint("AuthProvider: Error during auth state change: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      
      // Force sign out for permission/critical errors
      final err = e.toString().toLowerCase();
      if (err.contains('permission') || err.contains('denied')) {
        await _auth.signOut();
        _currentUser = null;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson(doc.data()!);
      } else {
        // Self-repair for missing Firestore document
        final newUser = UserModel(
          id: uid,
          email: _auth.currentUser?.email ?? '',
          displayName: _auth.currentUser?.displayName ?? 'User',
          role: UserRole.user,
          joinedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(uid).set(newUser.toJson());
        _currentUser = newUser;
      }
      
      // Subscribe to user specific topic for notifications
      if (_currentUser != null) {
        NotificationService.subscribeToUserTopic(_currentUser!.id);
      }
    } catch (e) {
      debugPrint("AuthProvider: Error fetching user details: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _setError(null);
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } catch (e) {
      debugPrint("AuthProvider: Login Error: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name, UserRole role) async {
    _isSigningUp = true;
    _setLoading(true);
    _setError(null);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      
      final newUser = UserModel(
        id: cred.user!.uid,
        email: email.trim(),
        displayName: name.trim(),
        role: role,
        points: 0,
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}',
        joinedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toJson());
      
      _currentUser = newUser;
      // Subscribe to user specific topic
      if (_currentUser != null) {
        NotificationService.subscribeToUserTopic(_currentUser!.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("AuthProvider: Signup Error: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      rethrow;
    } finally {
      _isSigningUp = false;
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      if (_currentUser != null) {
        await NotificationService.unsubscribeFromUserTopic(_currentUser!.id);
      }
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint("AuthProvider: Logout Error: $e");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setError(null);
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint("AuthProvider: Reset Password Error: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user exists in Firestore, if not create new
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!doc.exists) {
          final newUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'User',
            role: UserRole.user,
            points: 0,
            avatarUrl: firebaseUser.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${DateTime.now().millisecondsSinceEpoch}',
            joinedAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
          _currentUser = newUser;
        } else {
          _currentUser = UserModel.fromJson(doc.data()!);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("AuthProvider: Google Sign-In Error: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    if (_currentUser == null) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final Map<String, dynamic> updates = {};
      
      // Validate display name if provided
      if (displayName != null) {
        final trimmedName = displayName.trim();
        
        // Check length
        if (trimmedName.length < 3) {
          throw Exception('Name must be at least 3 characters long');
        }
        if (trimmedName.length > 30) {
          throw Exception('Name cannot exceed 30 characters');
        }
        
        // Check for invalid characters (allow letters, numbers, spaces only)
        final validNameRegex = RegExp(r'^[a-zA-Z0-9 ]+$');
        if (!validNameRegex.hasMatch(trimmedName)) {
          throw Exception('Name can only contain letters, numbers, and spaces');
        }
        
        updates['displayName'] = trimmedName;
      }
      
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      
      if (updates.isEmpty) return;

      await _firestore.collection('users').doc(_currentUser!.id).update(updates);
      
      _currentUser = _currentUser!.copyWith(
        displayName: displayName?.trim(),
        avatarUrl: avatarUrl,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint("AuthProvider: Update Profile Error: $e");
      _setError(AppErrorHandler.getErrorMessage(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> debugSwitchRole() async {
    if (_currentUser == null) return;
    final newRole = _currentUser!.role == UserRole.admin ? UserRole.user : UserRole.admin;
    
    // Optimistic Update
    final prevUser = _currentUser;
    _currentUser = _currentUser!.copyWith(role: newRole);
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({'role': newRole.name});
    } catch (e) {
      _currentUser = prevUser; // Rollback
      notifyListeners();
      debugPrint("AuthProvider: Sync Role Error: $e");
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) => UserModel.fromJson(doc.data()!))
          .toList();
    });
  }
}
