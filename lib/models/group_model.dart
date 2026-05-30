class GroupModel {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final List<String> pendingStudentIds;
  final String code;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.pendingStudentIds,
    required this.code,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'pendingStudentIds': pendingStudentIds,
      'code': code,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? []),
      pendingStudentIds: List<String>.from(json['pendingStudentIds'] ?? []),
      code: json['code'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    List<String>? pendingStudentIds,
    String? code,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      pendingStudentIds: pendingStudentIds ?? this.pendingStudentIds,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

