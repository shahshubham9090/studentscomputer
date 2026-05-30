import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_material_model.dart';
import '../core/error_handler.dart';

class MaterialProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<StudyMaterial> _materials = [];
  List<StudyMaterial> get materials => _materials;
  List<StudyMaterial> get visibleMaterials => _materials.where((m) => !m.isHidden).toList();

  String? _error;
  String? get error => _error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MaterialProvider() {
    _initListeners();
  }

  void _initListeners() {
    _isLoading = true;
    _firestore.collection('materials').snapshots().listen((snapshot) {
      _materials = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return StudyMaterial.fromJson(data);
      }).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = AppErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> addMaterial(StudyMaterial material) async {
    try {
      await _firestore.collection('materials').doc(material.id).set(material.toJson());
    } catch (e) {
      debugPrint("MaterialProvider: Add Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMaterial(StudyMaterial material) async {
    try {
      await _firestore.collection('materials').doc(material.id).update(material.toJson());
    } catch (e) {
      debugPrint("MaterialProvider: Update Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await _firestore.collection('materials').doc(materialId).delete();
    } catch (e) {
      debugPrint("MaterialProvider: Delete Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleHide(String materialId, bool currentlyHidden) async {
    try {
      await _firestore.collection('materials').doc(materialId).update({
        'isHidden': !currentlyHidden,
      });
    } catch (e) {
      debugPrint("MaterialProvider: Toggle Hide Error: $e");
      _error = AppErrorHandler.getErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }
}
