import 'package:hive/hive.dart';

part 'teacher.g.dart';

@HiveType(typeId: 0)
class Teacher extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late List<String> subjectIds; // IDs of subjects this teacher teaches

  @HiveField(3)
  late bool active;

  Teacher({
    required this.id,
    required this.name,
    required this.subjectIds,
    this.active = true,
  });

  Teacher copyWith({
    String? id,
    String? name,
    List<String>? subjectIds,
    bool? active,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      subjectIds: subjectIds ?? this.subjectIds,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subjectIds': subjectIds,
        'active': active,
      };
}
