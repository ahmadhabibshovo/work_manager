import 'package:flutter/material.dart';

enum AttachmentType {
  url,
  image;

  String get displayName {
    switch (this) {
      case AttachmentType.url:
        return 'URL';
      case AttachmentType.image:
        return 'Image';
    }
  }

  IconData get icon {
    switch (this) {
      case AttachmentType.url:
        return Icons.link;
      case AttachmentType.image:
        return Icons.image;
    }
  }
}

class TaskAttachment {
  final String id;
  final AttachmentType type;
  final String url; // For URLs, this is the actual URL. For images, this is the file path/URI
  final String? displayName; // Optional display name for the attachment
  final DateTime createdAt;

  const TaskAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.displayName,
    required this.createdAt,
  });

  TaskAttachment copyWith({
    String? id,
    AttachmentType? type,
    String? url,
    String? displayName,
    DateTime? createdAt,
  }) {
    return TaskAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as String,
      type: AttachmentType.values.firstWhere(
        (type) => type.name == json['type'] as String,
      ),
      url: json['url'] as String,
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'TaskAttachment(id: $id, type: $type, url: $url, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskAttachment &&
        other.id == id &&
        other.type == type &&
        other.url == url &&
        other.displayName == displayName &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        url.hashCode ^
        displayName.hashCode ^
        createdAt.hashCode;
  }
}