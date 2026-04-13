import 'package:equatable/equatable.dart';

/// InboxItem model matching the tududi backend InboxItem schema.
class InboxItem extends Equatable {
  final int? id;
  final String? uid;
  final String content;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InboxItem({
    this.id,
    this.uid,
    required this.content,
    this.status = 'added',
    this.createdAt,
    this.updatedAt,
  });

  bool get isProcessed => status == 'processed';
  bool get isIgnored => status == 'ignored';

  factory InboxItem.fromJson(Map<String, dynamic> json) {
    return InboxItem(
      id: json['id'] as int?,
      uid: json['uid'] as String?,
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'added',
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
    'content': content,
    'status': status,
  };

  @override
  List<Object?> get props => [id, uid];
}
