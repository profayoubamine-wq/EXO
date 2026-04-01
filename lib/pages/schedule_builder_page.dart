import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

const _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

class ScheduleBuilderPage extends StatefulWidget {
  final Session? existing;
  const ScheduleBuilderPage({super.key, this.existing});

  @override
  State<ScheduleBuilderPage> createState() => _ScheduleBuilderPageState();
}

class _ScheduleBuilderPageState extends State<ScheduleBuilderPage> {
  final _formKey = GlobalKey<FormState>();

  String? _levelId;
  String? _subjectId;
  String? _teacherId;
  String? _roomId;
  int _day = 0;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  int _durationMinutes = 90;

  bool _autoTeacher = true;
  bool _autoRoom = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final s = widget.existing!;
      _levelId = s.levelId;
      _subjectId = s.subjectId;
      _teacherId = s.teacherId;
      _roomId = s.roomId;
      _day = s.day;
      _startTime = TimeOfDay(hour: s.startHour, minute: s.startMinute);
      _durationMinutes = s.durationMinutes;
      _autoTeacher = false;
      _autoRoom = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل الحصة' : 'إضافة حصة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Level ──────────────────────────────────────
            _sectionLabel('المستوى'),
            DropdownButtonFormField<String>(
              value: _levelId,
              decoration: const InputDecoration(hintText: 'اختر المستوى'),
              items: prov.levels
                  .map((l) =>
                      DropdownMenuItem(value: l.id, child: Text(l.name)))
                  .toList(),
              onChanged: (v) => setState(() {
                _levelId = v;
                _subjectId = null;
              }),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // ── Subject ─────────────────────────────────────
            _sectionLabel('المادة'),
            DropdownButtonFormField<String>(
              value: _subjectId,
              decoration: const InputDecoration(hintText: 'اختر المادة'),
              items: (_levelId != null
                      ? prov.subjectsForLevel(_levelId!)
                      : prov.subjects)
                  .map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _subjectId = v),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // ── Day ─────────────────────────────────────────
            _sectionLabel('اليوم'),
            DropdownButtonFormField<int>(
              value: _day,
              items: List.generate(
                  _days.length,
                  (i) => DropdownMenuItem(
                      value: i, child: Text(_days[i]))).toList(),
              onChanged: (v) => setState(() => _day = v!),
            ),
            const SizedBox(height: 16),

            // ── Time ─────────────────────────────────────────
            _sectionLabel('وقت البداية'),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300)),
              tileColor: Colors.white,
              title: Text(
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.access_time, color: AppTheme.primary),
              onTap: () async {
                final picked = await showTimePicker(
                    context: context, initialTime: _startTime);
                if (picked != null) setState(() => _startTime = picked);
              },
            ),
            const SizedBox(height: 16),

            // ── Duration ─────────────────────────────────────
            _sectionLabel('المدة (دقيقة)'),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationMinutes.toDouble(),
                    min: 30,
                    max: 180,
                    divisions: 10,
                    label: '${_durationMinutes} د',
                    activeColor: AppTheme.primary,
                    onChanged: (v) =>
                        setState(() => _durationMinutes = v.round()),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('$_durationMinutes د',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Teacher ──────────────────────────────────────
            _sectionLabel('الأستاذ'),
            SwitchListTile(
              title: const Text('اختيار تلقائي'),
              value: _autoTeacher,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() {
                _autoTeacher = v;
                if (v) _teacherId = null;
              }),
            ),
            if (!_autoTeacher)
              DropdownButtonFormField<String>(
                value: _teacherId,
                decoration:
                    const InputDecoration(hintText: 'اختر الأستاذ'),
                items: prov.activeTeachers
                    .map((t) => DropdownMenuItem(
                        value: t.id, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _teacherId = v),
                validator: (v) =>
                    !_autoTeacher && v == null ? 'مطلوب' : null,
              ),
            const SizedBox(height: 16),

            // ── Room ─────────────────────────────────────────
            _sectionLabel('القاعة'),
            SwitchListTile(
              title: const Text('اختيار تلقائي'),
              value: _autoRoom,
              activeColor: AppTheme.primary,
              onChanged: (v) => setState(() {
                _autoRoom = v;
                if (v) _roomId = null;
              }),
            ),
            if (!_autoRoom)
              DropdownButtonFormField<String>(
                value: _roomId,
                decoration:
                    const InputDecoration(hintText: 'اختر القاعة'),
                items: prov.activeRooms
                    .map((r) => DropdownMenuItem(
                        value: r.id, child: Text(r.name)))
                    .toList(),
                onChanged: (v) => setState(() => _roomId = v),
                validator: (v) =>
                    !_autoRoom && v == null ? 'مطلوب' : null,
              ),
            const SizedBox(height: 30),

            // ── Save button ───────────────────────────────────
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(isEdit ? 'تحديث الحصة' : 'حفظ الحصة'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52)),
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final prov = context.read<AppProvider>();

    // Auto-assign teacher
    String? finalTeacherId = _teacherId;
    if (_autoTeacher) {
      if (_subjectId == null) {
        _showError('اختر المادة أولاً');
        setState(() => _isLoading = false);
        return;
      }
      final available = prov.availableTeachers(
        subjectId: _subjectId!,
        day: _day,
        startHour: _startTime.hour,
        startMinute: _startTime.minute,
        durationMinutes: _durationMinutes,
      );
      if (available.isEmpty) {
        _showError('⚠️ لا يوجد أستاذ متاح في هاد الوقت لهاد المادة');
        setState(() => _isLoading = false);
        return;
      }
      finalTeacherId = available.first.id;
    }

    // Auto-assign room
    String? finalRoomId = _roomId;
    if (_autoRoom) {
      final available = prov.availableRooms(
        day: _day,
        startHour: _startTime.hour,
        startMinute: _startTime.minute,
        durationMinutes: _durationMinutes,
      );
      if (available.isEmpty) {
        _showError('⚠️ لا توجد قاعة متاحة في هاد الوقت');
        setState(() => _isLoading = false);
        return;
      }
      finalRoomId = available.first.id;
    }

    final session = Session(
      id: widget.existing?.id ?? '',
      levelId: _levelId!,
      subjectId: _subjectId!,
      teacherId: finalTeacherId!,
      roomId: finalRoomId!,
      day: _day,
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      durationMinutes: _durationMinutes,
    );

    final error = await prov.saveSession(session);
    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else {
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primary)),
      );
}
