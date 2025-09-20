import 'package:flutter/material.dart';

enum Priority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.low:
        return Icons.arrow_downward;
      case Priority.medium:
        return Icons.remove;
      case Priority.high:
        return Icons.arrow_upward;
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return const Color(0xFF10B981); // Green
      case Priority.medium:
        return const Color(0xFFF59E0B); // Orange
      case Priority.high:
        return const Color(0xFFEF4444); // Red
    }
  }

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }

  static Priority fromValue(int value) {
    switch (value) {
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  static Priority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }
}