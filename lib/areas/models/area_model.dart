import 'package:equatable/equatable.dart';

/// Area model matching the tududi backend Area schema.
class Area extends Equatable {
  final int? id;
  final String? uid;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? projectCount;

  const Area({
    this.id,
    this.uid,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.projectCount,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
      projectCount: json['projectCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }

  Area copyWith({String? name, String? description}) {
    return Area(
      id: id,
      uid: uid,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      projectCount: projectCount,
    );
  }

  @override
  List<Object?> get props => [id, uid];
}
