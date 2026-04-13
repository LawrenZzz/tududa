import 'package:equatable/equatable.dart';

/// Tag model matching the tududi backend Tag schema.
class Tag extends Equatable {
  final int? id;
  final String? uid;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Tag({
    this.id,
    this.uid,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
  };

  @override
  List<Object?> get props => [id, name];
}
