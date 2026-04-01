import 'package:hive/hive.dart';

part 'level.g.dart';

@HiveType(typeId: 2)
class Level extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  Level({required this.id, required this.name});

  // Default levels for the center
  static List<Map<String, String>> get defaults => [
        {'id': 'pri1', 'name': 'Primaire 1'},
        {'id': 'pri2', 'name': 'Primaire 2'},
        {'id': '1ac', 'name': '1AC'},
        {'id': '2ac', 'name': '2AC'},
        {'id': '3ac', 'name': '3AC'},
        {'id': 'tcm', 'name': 'TCM'},
        {'id': '1bac', 'name': '1BAC'},
        {'id': '2bac', 'name': '2BAC'},
        {'id': 'bacl', 'name': 'Bac Lettre'},
        {'id': 'comfr', 'name': 'Communication FR'},
        {'id': 'comen', 'name': 'Communication Anglais'},
        {'id': 'cas1', 'name': 'CAS1'},
        {'id': 'cas2', 'name': 'CAS2'},
      ];
}
