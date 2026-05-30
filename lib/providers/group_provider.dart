import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GroupModel> _teacherGroups = [];
  List<GroupModel> get teacherGroups => _teacherGroups;

  List<GroupModel> _studentGroups = [];
  List<GroupModel> get studentGroups => _studentGroups;

  List<GroupModel> _pendingStudentGroups = [];
  List<GroupModel> get pendingStudentGroups => _pendingStudentGroups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Generate a random unique group code (6 characters alphanumeric)
  String _generateGroupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Create a new group (Teacher only)
  Future<void> createGroup(
    String name,
    String teacherId,
    String teacherName, {
    List<String> initialInvitedStudentIds = const [],
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final code = _generateGroupCode();
      final id = const Uuid().v4();
      
      final newGroup = GroupModel(
        id: id,
        name: name,
        teacherId: teacherId,
        teacherName: teacherName,
        studentIds: [],
        pendingStudentIds: initialInvitedStudentIds,
        code: code,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('groups').doc(id).set(newGroup.toJson());
      _teacherGroups.add(newGroup);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Join a group using a unique code (Student only)
  Future<bool> joinGroup(String code, String studentId) async {
    _setLoading(true);
    _error = null;
    try {
      // Find the group with the given code
      final query = await _firestore
          .collection('groups')
          .where('code', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _error = "Group code not found";
        notifyListeners();
        return false;
      }

      final doc = query.docs.first;
      final group = GroupModel.fromJson(doc.data());

      if (group.studentIds.contains(studentId)) {
        _error = "You are already a member of this group";
        notifyListeners();
        return false;
      }

      await _firestore.collection('groups').doc(group.id).update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });

      // Refresh student's groups list
      await fetchStudentGroups(studentId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch groups taught by a teacher
  Future<void> fetchTeacherGroups(String teacherId) async {
    _setLoading(true);
    _error = null;
    try {
      final query = await _firestore
          .collection('groups')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      _teacherGroups = query.docs.map((doc) => GroupModel.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch groups joined by a student
  Future<void> fetchStudentGroups(String studentId) async {
    _setLoading(true);
    _error = null;
    try {
      final query = await _firestore
          .collection('groups')
          .where('studentIds', arrayContains: studentId)
          .get();

      _studentGroups = query.docs.map((doc) => GroupModel.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all students (role = user)
  Future<List<UserModel>> fetchAllStudents() async {
    _error = null;
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.user.name)
          .get();
      return query.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Invite students to an existing group
  Future<void> inviteStudentsToGroup(String groupId, List<String> studentIds) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'pendingStudentIds': FieldValue.arrayUnion(studentIds),
      });
      // Update local state if present
      final idx = _teacherGroups.indexWhere((g) => g.id == groupId);
      if (idx != -1) {
        final currentGroup = _teacherGroups[idx];
        final updatedPending = List<String>.from(currentGroup.pendingStudentIds)
          ..addAll(studentIds);
        _teacherGroups[idx] = currentGroup.copyWith(pendingStudentIds: updatedPending);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch student's pending invites
  Future<void> fetchPendingStudentGroups(String studentId) async {
    _setLoading(true);
    _error = null;
    try {
      final query = await _firestore
          .collection('groups')
          .where('pendingStudentIds', arrayContains: studentId)
          .get();
      _pendingStudentGroups = query.docs.map((doc) => GroupModel.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Accept a group invitation
  Future<bool> acceptInvite(String groupId, String studentId) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'pendingStudentIds': FieldValue.arrayRemove([studentId]),
        'studentIds': FieldValue.arrayUnion([studentId]),
      });
      await fetchStudentGroups(studentId);
      await fetchPendingStudentGroups(studentId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Decline a group invitation
  Future<bool> declineInvite(String groupId, String studentId) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'pendingStudentIds': FieldValue.arrayRemove([studentId]),
      });
      await fetchPendingStudentGroups(studentId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
