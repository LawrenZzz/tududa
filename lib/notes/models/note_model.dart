import 'package:equatable/equatable.dart';

/// Note model matching the tududi backend Note schema.
class Note extends Equatable {
  final int? id;
  final String? uid;
  final String? title;
  final String? content;
  final String? color;
  final int? projectId;
  final String? projectName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    this.id,
    this.uid,
    this.title,
    this.content,
    this.color,
    this.projectId,
    this.projectName,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      color: json['color'] as String?,
      projectId: json['project_id'] as int?,
      projectName: json['Project'] != null
          ? json['Project']['name'] as String?
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'color': color,
      'project_id': projectId,
    };
  }

  Note copyWith({
    String? title,
    String? content,
    String? color,
    int? projectId,
  }) {
    return Note(
      id: id,
      uid: uid,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      projectId: projectId ?? this.projectId,
      projectName: projectName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, uid];
}
