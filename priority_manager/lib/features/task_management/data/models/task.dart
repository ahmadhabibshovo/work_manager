import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String priority; // 'Low', 'Medium', 'High'

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String? categoryId;

  @HiveField(6)
  List<String> attachments; // File paths

  @HiveField(7)
  String syncStatus; // 'pending', 'synced'

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.dueDate,
    this.categoryId,
    this.attachments = const [],
    this.syncStatus = 'pending',
  });
}