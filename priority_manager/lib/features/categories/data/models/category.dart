import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String syncStatus;

  Category({
    required this.id,
    required this.name,
    this.syncStatus = 'pending',
  });
}