import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/data_service.dart';
import '../models/session.dart';

const _daysLong = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

class PdfService {
  static const String centerName = 'EXO Ayoub';

  // ── 1. Full center timetable ────────────────────────────
  static Future<void> exportFullTimetable() async {
    final pdf = pw.Document();
    final levels = DataService.levels;

    for (final level in levels) {
      final sessions = DataService.sessionsForLevel(level.id);
      if (sessions.isEmpty) continue;
      pdf.addPage(_buildLevelPage(level.name, sessions));
    }

    if (pdf.document.pdfPageList.pages.isEmpty) return;
    await Printing.layoutPdf(onLayout: (f) async => pdf.save());
  }

  // ── 2. Timetable per level ──────────────────────────────
  static Future<void> exportLevelTimetable(String levelId) async {
    final level = DataService.getLevel(levelId);
    if (level == null) return;
    final sessions = DataService.sessionsForLevel(levelId);

    final pdf = pw.Document();
    pdf.addPage(_buildLevelPage(level.name, sessions));
    await Printing.layoutPdf(onLayout: (f) async => pdf.save());
  }

  // ── 3. Timetable per teacher ────────────────────────────
  static Future<void> exportTeacherTimetable(String teacherId) async {
    final teacher = DataService.getTeacher(teacherId);
    if (teacher == null) return;
    final sessions = DataService.sessionsForTeacher(teacherId);

    final pdf = pw.Document();
    pdf.addPage(_buildLevelPage('Prof: ${teacher.name}', sessions));
    await Printing.layoutPdf(onLayout: (f) async => pdf.save());
  }

  // ── Page builder ────────────────────────────────────────
  static pw.Page _buildLevelPage(String title, List<Session> sessions) {
    // Group sessions by day
    Map<int, List<Session>> byDay = {};
    for (final s in sessions) {
      byDay.putIfAbsent(s.day, () => []).add(s);
    }
    for (final list in byDay.values) {
      list.sort((a, b) =>
          (a.startHour * 60 + a.startMinute)
              .compareTo(b.startHour * 60 + b.startMinute));
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Center(
            child: pw.Text(centerName,
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900)),
          ),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text('Emploi du Temps — $title',
                style: pw.TextStyle(
                    fontSize: 15, color: PdfColors.grey700)),
          ),
          pw.Divider(color: PdfColors.blue900, thickness: 2),
          pw.SizedBox(height: 12),

          // Table
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blue900),
            headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.center,
            headers: ['Jour', 'Heure début', 'Heure fin', 'Matière', 'Prof', 'Salle'],
            data: [
              for (int d = 0; d < 6; d++)
                ...(byDay[d] ?? []).map((s) {
                  final subj = DataService.getSubject(s.subjectId);
                  final teacher = DataService.getTeacher(s.teacherId);
                  final room = DataService.getRoom(s.roomId);
                  return [
                    _daysLong[d],
                    s.startTimeStr,
                    s.endTimeStr,
                    subj?.name ?? '—',
                    teacher?.name ?? '—',
                    room?.name ?? '—',
                  ];
                }),
            ],
          ),
        ],
      ),
    );
  }
}
