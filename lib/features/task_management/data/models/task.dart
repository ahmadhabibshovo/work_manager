import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'priority.dart';
import 'task_attachment.dart';

part 'task.g.dart';

@HiveType(typeId: 5)
class Task {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final Priority priority;
  @HiveField(4)
  final bool isCompleted;
  @HiveField(5)
  final DateTime? dueDate;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime? updatedAt;
  @HiveField(8)
  final String? categoryId;
  @HiveField(9)
  final List<TaskAttachment> attachments;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
    this.categoryId,
    this.attachments = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryId,
    List<TaskAttachment>? attachments,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'categoryId': categoryId,
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: Priority.fromString(json['priority'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      categoryId: json['categoryId'] as String?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List<dynamic>)
              .map((attachmentJson) => TaskAttachment.fromJson(attachmentJson as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.isCompleted == isCompleted &&
        other.dueDate == dueDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.categoryId == categoryId &&
        listEquals(other.attachments, attachments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        priority.hashCode ^
        isCompleted.hashCode ^
        dueDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        categoryId.hashCode ^
        attachments.hashCode;
  }
}