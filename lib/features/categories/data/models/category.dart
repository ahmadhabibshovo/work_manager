import 'package:flutter/material.dart';

enum CategoryType {
  personal,
  work,
  health,
  finance,
  education,
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

class Category {
  final String id;
  final String name;
  final CategoryType type;
  final Color? customColor;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.customColor,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

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
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      customColor: customColor ?? this.customColor,
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