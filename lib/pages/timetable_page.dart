import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';
import 'schedule_builder_page.dart';

const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
const _daysLong = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String? _selectedLevelId;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الحصص'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScheduleBuilderPage()));
              if (result == true) setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Level selector
          Container(
            color: AppTheme.primary.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedLevelId,
              decoration: const InputDecoration(
                hintText: 'اختر المستوى لعرض جدوله',
                prefixIcon: Icon(Icons.school, color: AppTheme.primary),
              ),
              items: prov.levels
                  .map((l) =>
                      DropdownMenuItem(value: l.id, child: Text(l.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLevelId = v),
            ),
          ),

          if (_selectedLevelId == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('اختر مستوى لعرض الجدول',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: _buildGrid(prov),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(AppProvider prov) {
    final sessions = prov.sessionsForLevel(_selectedLevelId!);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('لا توجد حصص بعد',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('أضف حصة'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScheduleBuilderPage())),
            ),
          ],
        ),
      );
    }

    // Group by day
    Map<int, List<Session>> byDay = {};
    for (final s in sessions) {
      byDay.putIfAbsent(s.day, () => []).add(s);
    }
    // Sort each day by time
    for (final list in byDay.values) {
      list.sort((a, b) =>
          (a.startHour * 60 + a.startMinute)
              .compareTo(b.startHour * 60 + b.startMinute));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: List.generate(6, (dayIdx) {
        final daySessions = byDay[dayIdx] ?? [];
        if (daySessions.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_daysLong[dayIdx],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ...daySessions.map((s) => _sessionCard(s, prov)),
          ],
        );
      }),
    );
  }

  Widget _sessionCard(Session s, AppProvider prov) {
    final color = Color(prov.subjectColor(s.subjectId));
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Row(
          children: [
            Text(
              prov.subjectName(s.subjectId),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const Spacer(),
            Text(
              '${s.startTimeStr} → ${s.endTimeStr}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.person, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Text(prov.teacherName(s.teacherId),
                style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.meeting_room, size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Text(prov.roomName(s.roomId),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'edit') {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ScheduleBuilderPage(existing: s)));
              setState(() {});
            } else if (val == 'delete') {
              _confirmDelete(s.id);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('تعديل')),
            const PopupMenuItem(
                value: 'delete',
                child: Text('حذف', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحصة'),
        content: const Text('هل تبغي تحذف هاد الحصة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppProvider>().deleteSession(id);
              Navigator.pop(ctx);
              setState(() {});
            },
            child:
                const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
