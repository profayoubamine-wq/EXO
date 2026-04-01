import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/pdf_service.dart';
import 'timetable_page.dart';
import 'settings_page.dart';
import 'schedule_builder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    _DashboardTab(),
    TimetablePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primary,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'الجدول'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Dashboard Tab
// ═══════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXO Ayoub'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.picture_as_pdf),
            onSelected: (val) async {
              if (val == 'full') {
                await PdfService.exportFullTimetable();
              } else if (val == 'level') {
                _showLevelPdfDialog(context);
              } else if (val == 'teacher') {
                _showTeacherPdfDialog(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'full',
                  child: ListTile(
                      leading: Icon(Icons.grid_on),
                      title: Text('الجدول الكامل'))),
              const PopupMenuItem(
                  value: 'level',
                  child: ListTile(
                      leading: Icon(Icons.school),
                      title: Text('حسب المستوى'))),
              const PopupMenuItem(
                  value: 'teacher',
                  child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('حسب الأستاذ'))),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ScheduleBuilderPage())),
        icon: const Icon(Icons.add),
        label: const Text('إضافة حصة'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats row
          Row(
            children: [
              _statCard('الحصص', '${prov.sessions.length}', Icons.event,
                  AppTheme.primary),
              const SizedBox(width: 12),
              _statCard('الأساتذة', '${prov.activeTeachers.length}',
                  Icons.person, AppTheme.success),
              const SizedBox(width: 12),
              _statCard('القاعات', '${prov.activeRooms.length}',
                  Icons.meeting_room, AppTheme.accent),
            ],
          ),
          const SizedBox(height: 20),

          // Quick access by level
          const Text('الجداول حسب المستوى',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primary)),
          const SizedBox(height: 10),
          ...prov.levels.map((l) {
            final count = prov.sessionsForLevel(l.id).length;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0x1A1565C0),
                  child: Icon(Icons.school, color: AppTheme.primary),
                ),
                title: Text(l.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text('$count حصة',
                          style: const TextStyle(fontSize: 11)),
                      backgroundColor:
                          AppTheme.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppTheme.primary),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Colors.red),
                      onPressed: () =>
                          PdfService.exportLevelTimetable(l.id),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  void _showLevelPdfDialog(BuildContext context) {
    final prov = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر المستوى'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: prov.levels
                .map((l) => ListTile(
                      title: Text(l.name),
                      onTap: () {
                        Navigator.pop(ctx);
                        PdfService.exportLevelTimetable(l.id);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showTeacherPdfDialog(BuildContext context) {
    final prov = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر الأستاذ'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: prov.teachers
                .map((t) => ListTile(
                      title: Text(t.name),
                      onTap: () {
                        Navigator.pop(ctx);
                        PdfService.exportTeacherTimetable(t.id);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
