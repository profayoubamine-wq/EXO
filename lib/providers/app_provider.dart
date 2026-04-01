import 'package:flutter/material.dart';
import '../data/data_service.dart';
import '../models/teacher.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../models/room.dart';
import '../models/session.dart';

class AppProvider extends ChangeNotifier {
  // ─── Getters (always fresh from Hive) ──────────────────
  List<Teacher> get teachers => DataService.teachers;
  List<Teacher> get activeTeachers => DataService.activeTeachers;
  List<Subject> get subjects => DataService.subjects;
  List<Level> get levels => DataService.levels;
  List<Room> get rooms => DataService.rooms;
  List<Room> get activeRooms => DataService.activeRooms;
  List<Session> get sessions => DataService.sessions;

  // ─── Teachers ──────────────────────────────────────────
  Future<void> saveTeacher(Teacher t) async {
    await DataService.saveTeacher(t);
    notifyListeners();
  }

  Future<void> deleteTeacher(String id) async {
    await DataService.deleteTeacher(id);
    notifyListeners();
  }

  Future<void> toggleTeacherActive(String id) async {
    final t = DataService.getTeacher(id);
    if (t == null) return;
    t.active = !t.active;
    await DataService.saveTeacher(t);
    notifyListeners();
  }

  // ─── Subjects ──────────────────────────────────────────
  Future<void> saveSubject(Subject s) async {
    await DataService.saveSubject(s);
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    await DataService.deleteSubject(id);
    notifyListeners();
  }

  List<Subject> subjectsForLevel(String levelId) =>
      DataService.subjectsForLevel(levelId);

  // ─── Levels ────────────────────────────────────────────
  Future<void> saveLevel(Level l) async {
    await DataService.saveLevel(l);
    notifyListeners();
  }

  Future<void> deleteLevel(String id) async {
    await DataService.deleteLevel(id);
    notifyListeners();
  }

  // ─── Rooms ─────────────────────────────────────────────
  Future<void> saveRoom(Room r) async {
    await DataService.saveRoom(r);
    notifyListeners();
  }

  Future<void> deleteRoom(String id) async {
    await DataService.deleteRoom(id);
    notifyListeners();
  }

  Future<void> toggleRoomActive(String id) async {
    final r = DataService.getRoom(id);
    if (r == null) return;
    r.active = !r.active;
    await DataService.saveRoom(r);
    notifyListeners();
  }

  // ─── Sessions ──────────────────────────────────────────

  /// Returns null on success, error message on conflict
  Future<String?> saveSession(Session s) async {
    final result = await DataService.saveSession(s);
    if (result == null) notifyListeners();
    return result;
  }

  Future<void> deleteSession(String id) async {
    await DataService.deleteSession(id);
    notifyListeners();
  }

  List<Session> sessionsForLevel(String levelId) =>
      DataService.sessionsForLevel(levelId);

  List<Session> sessionsForTeacher(String teacherId) =>
      DataService.sessionsForTeacher(teacherId);

  // ─── Auto helpers ──────────────────────────────────────
  List<Teacher> availableTeachers({
    required String subjectId,
    required int day,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) =>
      DataService.availableTeachers(
        subjectId: subjectId,
        day: day,
        startHour: startHour,
        startMinute: startMinute,
        durationMinutes: durationMinutes,
      );

  List<Room> availableRooms({
    required int day,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
  }) =>
      DataService.availableRooms(
        day: day,
        startHour: startHour,
        startMinute: startMinute,
        durationMinutes: durationMinutes,
      );

  // Lookup helpers
  String teacherName(String id) =>
      DataService.getTeacher(id)?.name ?? '—';
  String subjectName(String id) =>
      DataService.getSubject(id)?.name ?? '—';
  String levelName(String id) =>
      DataService.getLevel(id)?.name ?? '—';
  String roomName(String id) =>
      DataService.getRoom(id)?.name ?? '—';
  int subjectColor(String id) =>
      DataService.getSubject(id)?.colorValue ?? 0xFF9E9E9E;
}
