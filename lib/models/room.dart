import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 3)
class Room extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String type; // 'large' | 'medium' | 'small' | 'meeting'

  @HiveField(3)
  late bool active;

  Room({
    required this.id,
    required this.name,
    required this.type,
    this.active = true,
  });

  bool get isMeeting => type == 'meeting';

  Room copyWith({String? id, String? name, String? type, bool? active}) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      active: active ?? this.active,
    );
  }
}
