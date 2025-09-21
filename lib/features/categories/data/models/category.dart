import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
enum CategoryType {
  @HiveField(0)
  personal,
  @HiveField(1)
  work,
  @HiveField(2)
  health,
  @HiveField(3)
  finance,
  @HiveField(4)
  education,
  @HiveField(5)
  other;

  String get displayName {
    switch (this) {
      case CategoryType.personal:
        return 'Personal';
      case CategoryType.work:
        return 'Work';
      case CategoryType.health:
        return 'Health';
      case CategoryType.finance:
        return 'Finance';
      case CategoryType.education:
        return 'Education';
      case CategoryType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.personal:
        return Icons.person;
      case CategoryType.work:
        return Icons.work;
      case CategoryType.health:
        return Icons.health_and_safety;
      case CategoryType.finance:
        return Icons.account_balance_wallet;
      case CategoryType.education:
        return Icons.school;
      case CategoryType.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.personal:
        return const Color(0xFF6366F1);
      case CategoryType.work:
        return const Color(0xFF8B5CF6);
      case CategoryType.health:
        return const Color(0xFF10B981);
      case CategoryType.finance:
        return const Color(0xFFF59E0B);
      case CategoryType.education:
        return const Color(0xFFEF4444);
      case CategoryType.other:
        return const Color(0xFF6B7280);
    }
  }
}

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final CategoryType type;
  @HiveField(3)
  final int? customColorValue; // Store color as int
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    Color? customColor,
    this.description,
    required this.createdAt,
    this.updatedAt,
  }) : customColorValue = null;

  // Factory constructor for creating from stored data
  factory Category.fromStored({
    required String id,
    required String name,
    required CategoryType type,
    int? customColorValue,
    String? description,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    return Category._internal(
      id: id,
      name: name,
      type: type,
      customColorValue: customColorValue,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  const Category._internal({
    required this.id,
    required this.name,
    required this.type,
    this.customColorValue,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  // Getter to convert int back to Color
  Color? get customColor => customColorValue != null ? Color(customColorValue!) : null;

  Color get color => customColor ?? type.color;

  IconData get icon => type.icon;

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    Color? customColor,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category._internal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      customColorValue: customColor?.value ?? customColorValue,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'customColor': customColor?.value,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => CategoryType.other,
      ),
      customColor: json['customColor'] != null
          ? Color(json['customColor'] as int)
          : null,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.customColor == customColor &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        customColor.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}