import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 1)
class Subject extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String levelId;

  @HiveField(3)
  late int colorValue; // Color as int (e.g. Colors.blue.value)

  Subject({
    required this.id,
    required this.name,
    required this.levelId,
    required this.colorValue,
  });

  Subject copyWith({
    String? id,
    String? name,
    String? levelId,
    int? colorValue,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      levelId: levelId ?? this.levelId,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
