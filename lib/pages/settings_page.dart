import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/teacher.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _settingsTile(context, Icons.person, 'الأساتذة', Colors.blue,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TeachersSettingsPage()))),
          _settingsTile(context, Icons.book, 'المواد', Colors.green,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubjectsSettingsPage()))),
          _settingsTile(context, Icons.meeting_room, 'القاعات', Colors.orange,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RoomsSettingsPage()))),
          _settingsTile(context, Icons.school, 'المستويات', Colors.purple,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LevelsSettingsPage()))),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TEACHERS
// ═══════════════════════════════════════════════════════════
class TeachersSettingsPage extends StatelessWidget {
  const TeachersSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الأساتذة')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTeacherDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: prov.teachers.isEmpty
          ? const Center(child: Text('لا يوجد أساتذة بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prov.teachers.length,
              itemBuilder: (ctx, i) {
                final t = prov.teachers[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.active
                          ? AppTheme.primary.withOpacity(0.15)
                          : Colors.grey.shade200,
                      child: Icon(Icons.person,
                          color: t.active ? AppTheme.primary : Colors.grey),
                    ),
                    title: Text(t.name),
                    subtitle: Text(
                        t.subjectIds.isEmpty
                            ? 'بدون مواد'
                            : t.subjectIds
                                .map((id) =>
                                    context.read<AppProvider>().subjectName(id))
                                .join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: t.active,
                          onChanged: (_) =>
                              prov.toggleTeacherActive(t.id),
                          activeColor: AppTheme.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTeacherDialog(context, t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(
                              context, () => prov.deleteTeacher(t.id)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTeacherDialog(BuildContext context, Teacher? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final prov = context.read<AppProvider>();
    List<String> selectedSubjects =
        List.from(existing?.subjectIds ?? []);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'إضافة أستاذ' : 'تعديل أستاذ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('المواد:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...prov.subjects.map((s) => CheckboxListTile(
                      title: Text(s.name),
                      value: selectedSubjects.contains(s.id),
                      onChanged: (val) => setSt(() {
                        if (val == true) {
                          selectedSubjects.add(s.id);
                        } else {
                          selectedSubjects.remove(s.id);
                        }
                      }),
                      dense: true,
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final teacher = Teacher(
                  id: existing?.id ?? '',
                  name: nameCtrl.text.trim(),
                  subjectIds: selectedSubjects,
                  active: existing?.active ?? true,
                );
                prov.saveTeacher(teacher);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تبغي تحذف هاد العنصر؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SUBJECTS
// ═══════════════════════════════════════════════════════════
class SubjectsSettingsPage extends StatelessWidget {
  const SubjectsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('المواد')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: prov.subjects.isEmpty
          ? const Center(child: Text('لا توجد مواد بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prov.subjects.length,
              itemBuilder: (ctx, i) {
                final s = prov.subjects[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Color(s.colorValue).withOpacity(0.8),
                        child: Text(s.name[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                    title: Text(s.name),
                    subtitle: Text(prov.levelName(s.levelId)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showSubjectDialog(context, s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(
                              context, () => prov.deleteSubject(s.id)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSubjectDialog(BuildContext context, Subject? existing) {
    final prov = context.read<AppProvider>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String? selectedLevel = existing?.levelId;
    int selectedColor =
        existing?.colorValue ?? AppTheme.subjectColors[0].value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'إضافة مادة' : 'تعديل مادة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المادة'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(labelText: 'المستوى'),
                  items: prov.levels
                      .map((l) => DropdownMenuItem(
                          value: l.id, child: Text(l.name)))
                      .toList(),
                  onChanged: (v) => setSt(() => selectedLevel = v),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('اللون:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppTheme.subjectColors
                      .map((c) => GestureDetector(
                            onTap: () =>
                                setSt(() => selectedColor = c.value),
                            child: CircleAvatar(
                              backgroundColor: c,
                              radius: 16,
                              child: selectedColor == c.value
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 16)
                                  : null,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    selectedLevel == null) return;
                final subject = Subject(
                  id: existing?.id ?? '',
                  name: nameCtrl.text.trim(),
                  levelId: selectedLevel!,
                  colorValue: selectedColor,
                );
                prov.saveSubject(subject);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تبغي تحذف هاد المادة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ROOMS
// ═══════════════════════════════════════════════════════════
class RoomsSettingsPage extends StatelessWidget {
  const RoomsSettingsPage({super.key});

  static const _types = ['large', 'medium', 'small', 'meeting'];
  static const _typeLabels = ['كبيرة', 'متوسطة', 'صغيرة', 'اجتماعات'];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('القاعات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoomDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: prov.rooms.isEmpty
          ? const Center(child: Text('لا توجد قاعات بعد'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: prov.rooms.length,
              itemBuilder: (ctx, i) {
                final r = prov.rooms[i];
                final typeIdx = _types.indexOf(r.type);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: r.active
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.grey.shade200,
                      child: Icon(Icons.meeting_room,
                          color: r.active ? Colors.orange : Colors.grey),
                    ),
                    title: Text(r.name),
                    subtitle: Text(typeIdx >= 0
                        ? _typeLabels[typeIdx]
                        : r.type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.active,
                          onChanged: (_) => prov.toggleRoomActive(r.id),
                          activeColor: Colors.orange,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRoomDialog(context, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(
                              context, () => prov.deleteRoom(r.id)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showRoomDialog(BuildContext context, Room? existing) {
    final prov = context.read<AppProvider>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String selectedType = existing?.type ?? 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'إضافة قاعة' : 'تعديل قاعة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم القاعة'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'النوع'),
                items: List.generate(
                    _types.length,
                    (i) => DropdownMenuItem(
                        value: _types[i],
                        child: Text(_typeLabels[i]))).toList(),
                onChanged: (v) => setSt(() => selectedType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final room = Room(
                  id: existing?.id ?? '',
                  name: nameCtrl.text.trim(),
                  type: selectedType,
                  active: existing?.active ?? true,
                );
                prov.saveRoom(room);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تبغي تحذف هاد القاعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// LEVELS
// ═══════════════════════════════════════════════════════════
class LevelsSettingsPage extends StatelessWidget {
  const LevelsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('المستويات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLevelDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: prov.levels.length,
        itemBuilder: (ctx, i) {
          final l = prov.levels[i];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0x1A9C27B0),
                child: Icon(Icons.school, color: Colors.purple),
              ),
              title: Text(l.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showLevelDialog(context, l),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(
                        context, () => prov.deleteLevel(l.id)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLevelDialog(BuildContext context, Level? existing) {
    final prov = context.read<AppProvider>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'إضافة مستوى' : 'تعديل مستوى'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'اسم المستوى'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final level = Level(
                id: existing?.id ?? '',
                name: nameCtrl.text.trim(),
              );
              prov.saveLevel(level);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تبغي تحذف هاد المستوى؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child:
                const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
