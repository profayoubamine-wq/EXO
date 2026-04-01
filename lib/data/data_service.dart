import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/teacher.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../models/room.dart';
import '../models/session.dart';

const _uuid = Uuid();

class DataService {
  static late Box<Teacher> _teachers;
  static late Box<Subject> _subjects;
  static late Box<Level> _levels;
  static late Box<Room> _rooms;
  static late Box<Session> _sessions;

  // ─── Init ───────────────────────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TeacherAdapter());
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(LevelAdapter());
    Hive.registerAdapter(RoomAdapter());
    Hive.registerAdapter(SessionAdapter());

    _teachers = await Hive.openBox<Teacher>('teachers');
    _subjects = await Hive.openBox<Subject>('subjects');
    _levels = await Hive.openBox<Level>('levels');
    _rooms = await Hive.openBox<Room>('rooms');
    _sessions = await Hive.openBox<Session>('sessions');

    // Seed default levels if empty
    if (_levels.isEmpty) await _seedLevels();
  }

  static Future<void> _seedLevels() async {
    for (final l in Level.defaults) {
      await _levels.put(l['id']!, Level(id: l['id']!, name: l['name']!));
    }
  }

  // ─── Teachers ───────────────────────────────────────────
  static List<Teacher> get teachers => _teachers.values.toList();
  static List<Teacher> get activeTeachers =>
      _teachers.values.where((t) => t.active).toList();

  static Future<void> saveTeacher(Teacher t) async {
    if (t.id.isEmpty) t.id = _uuid.v4();
    await _teachers.put(t.id, t);
  }

  static Future<void> deleteTeacher(String id) async =>
      await _teachers.delete(id);

  static Teacher? getTeacher(String id) => _teachers.get(id);

  // ─── Subjects ───────────────────────────────────────────
  static List<Subject> get subjects => _subjects.values.toList();

  static List<Subject> subjectsForLevel(String levelId) =>
      _subjects.values.where((s) => s.levelId == levelId).toList();

  static Future<void> saveSubject(Subject s) async {
    if (s.id.isEmpty) s.id = _uuid.v4();
    await _subjects.put(s.id, s);
  }

  static Future<void> deleteSubject(String id) async =>
      await _subjects.delete(id);

  static Subject? getSubject(String id) => _subjects.get(id);

  // ─── Levels ─────────────────────────────────────────────
  static List<Level> get levels => _levels.values.toList();

  static Future<void> saveLevel(Level l) async {
    if (l.id.isEmpty) l.id = _uuid.v4();
    await _levels.put(l.id, l);
  }

  static Future<void> deleteLevel(String id) async =>
      await _levels.delete(id);

  static Level? getLevel(String id) => _levels.get(id);

  // ─── Rooms ──────────────────────────────────────────────
  static List<Room> get rooms => _rooms.values.toList();
  static List<Room> get activeRooms =>
      _rooms.values.where((r) => r.active).toList();

  static Future<void> saveRoom(Room r) async {
    if (r.id.isEmpty) r.id = _uuid.v4();
    await _rooms.put(r.id, r);
  }

  static Future<void> deleteRoom(String id) async => await _rooms.delete(id);

  static Room? getRoom(String id) => _rooms.get(id);

  // ─── Sessions ───────────────────────────────────────────
  static List<Session> get sessions => _sessions.values.toList();

  static List<Session> sessionsForLevel(String levelId) =>
      _sessions.values.where((s) => s.levelId == levelId).toList();

  static List<Session> sessionsForTeacher(String teacherId) =>
      _sessions.values.where((s) => s.teacherId == teacherId).toList();

  static List<Session> sessionsForDay(int day) =>
      _sessions.values.where((s) => s.day == day).toList();

  static Future<String?> saveSession(Session s) async {
    // Conflict check
    String? conflict = checkConflicts(s);
    if (conflict != null) return conflict;

    if (s.id.isEmpty) s.id = _uuid.v4();
    await _sessions.put(s.id, s);
    return null; // null = no error
  }

  static Future<void> deleteSession(String id) async =>
      await _sessions.delete(id);

  static Session? getSession(String id) => _sessions.get(id);

  // ─── Conflict Detection ─────────────────────────────────
  static String? checkConflicts(Session newSession, {String? excludeId}) {
    final existing = _sessions.values
        .where((s) => s.id != excludeId)
        .toList();

    for (final s in existing) {
      if (!newSession.overlapsWith(s)) continue;

      if (s.teacherId == newSession.teacherId) {
        final teacher = getTeacher(s.teacherId);
        return '⚠️ الأستاذ ${teacher?.name ?? ''} مشغول في هاد الوقت';
      }
      if (s.roomId == newSession.roomId) {
        final room = getRoom(s.roomId);
        return '⚠️ القاعة ${room?.name ?? ''} مشغولة في هاد الوقت';
      }
      if (s.levelId == newSession.levelId) {
        final level = getLevel(s.levelId);
        return '⚠️ المستوى ${level?.name ?? ''} عنده حصة في هاد الوقت';
      }
    }
    return null;
  }

  // ─── Auto-assign helpers ────────────────────────────────

  /// Returns available teachers for a subject at a given day/time
  static List<Teacher> availableTeachers({
    required String subjectId,
    required int day,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) {
    final probe = Session(
      id: '__probe__',
      levelId: '',
      subjectId: subjectId,
      teacherId: '',
      roomId: '',
      day: day,
      startHour: startHour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
    );

    return activeTeachers.where((t) {
      if (!t.subjectIds.contains(subjectId)) return false;
      final busy = sessionsForTeacher(t.id).any((s) => probe.overlapsWith(s));
      return !busy;
    }).toList();
  }

  /// Returns available rooms at a given day/time (non-meeting preferred)
  static List<Room> availableRooms({
    required int day,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) {
    final probe = Session(
      id: '__probe__',
      levelId: '',
      subjectId: '',
      teacherId: '',
      roomId: '',
      day: day,
      startHour: startHour,
      startMinute: startMinute,
      durationMinutes: durationMinutes,
    );

    final busyRoomIds = sessions
        .where((s) => probe.overlapsWith(s))
        .map((s) => s.roomId)
        .toSet();

    final available = activeRooms
        .where((r) => !busyRoomIds.contains(r.id))
        .toList();

    // Sort: non-meeting first
    available.sort((a, b) {
      if (a.isMeeting && !b.isMeeting) return 1;
      if (!a.isMeeting && b.isMeeting) return -1;
      return 0;
    });

    return available;
  }
}
