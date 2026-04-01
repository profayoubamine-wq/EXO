import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 4)
class Session extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String levelId;

  @HiveField(2)
  late String subjectId;

  @HiveField(3)
  late String teacherId;

  @HiveField(4)
  late String roomId;

  @HiveField(5)
  late int day; // 0=Lundi, 1=Mardi, ... 5=Samedi, 6=Dimanche

  @HiveField(6)
  late int startHour;

  @HiveField(7)
  late int startMinute;

  @HiveField(8)
  late int durationMinutes; // default 90 (1h30)

  Session({
    required this.id,
    required this.levelId,
    required this.subjectId,
    required this.teacherId,
    required this.roomId,
    required this.day,
    required this.startHour,
    required this.startMinute,
    this.durationMinutes = 90,
  });

  // Computed end time
  int get endHour {
    int totalMinutes = startHour * 60 + startMinute + durationMinutes;
    return totalMinutes ~/ 60;
  }

  int get endMinute {
    int totalMinutes = startHour * 60 + startMinute + durationMinutes;
    return totalMinutes % 60;
  }

  String get startTimeStr =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endTimeStr =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  String get dayName {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[day];
  }

  // Check if this session overlaps with another
  bool overlapsWith(Session other) {
    if (day != other.day) return false;
    int startA = startHour * 60 + startMinute;
    int endA = startA + durationMinutes;
    int startB = other.startHour * 60 + other.startMinute;
    int endB = startB + other.durationMinutes;
    return startA < endB && startB < endA;
  }

  Session copyWith({
    String? id,
    String? levelId,
    String? subjectId,
    String? teacherId,
    String? roomId,
    int? day,
    int? startHour,
    int? startMinute,
    int? durationMinutes,
  }) {
    return Session(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      roomId: roomId ?? this.roomId,
      day: day ?? this.day,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
