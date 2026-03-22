class ActivityModel {
  final int id;
  final String? docId;
  final String name;
  final String? description;
  final String? schedule;
  final int? capacity;
  final String? teacher;
  final String? ageGroup;
  final String? createdAt;

  const ActivityModel({
    required this.id,
    this.docId,
    required this.name,
    this.description,
    this.schedule,
    this.capacity,
    this.teacher,
    this.ageGroup,
    this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int,
      docId: json['docId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      schedule: json['schedule'] as String?,
      capacity: json['capacity'] as int?,
      teacher: json['teacher'] as String?,
      ageGroup: json['age_group'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ActivityModel(
      id: (map['id'] as int?) ?? 0,
      docId: docId,
      name: map['name'] as String,
      description: map['description'] as String?,
      schedule: map['schedule'] as String?,
      capacity: map['capacity'] as int?,
      teacher: map['teacher'] as String?,
      ageGroup: map['age_group'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (docId != null) 'docId': docId,
      'name': name,
      if (description != null) 'description': description,
      if (schedule != null) 'schedule': schedule,
      if (capacity != null) 'capacity': capacity,
      if (teacher != null) 'teacher': teacher,
      if (ageGroup != null) 'age_group': ageGroup,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (schedule != null) 'schedule': schedule,
      if (capacity != null) 'capacity': capacity,
      if (teacher != null) 'teacher': teacher,
      if (ageGroup != null) 'age_group': ageGroup,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}
