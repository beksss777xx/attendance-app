import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/study_class.dart';
import '../providers/attendance_notifier.dart';
import '../services/export_service.dart';
import '../widgets/add_student_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/student_attendance_tile.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({super.key, required this.studyClass});

  final StudyClass studyClass;

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late DateTime _selectedDate;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _selectedDate = DateTime(n.year, n.month, n.day);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _showExportSheet(
    BuildContext context,
    AttendanceNotifier notifier,
  ) async {
    final text = notifier.buildExportText(
      classId: widget.studyClass.id,
      date: _selectedDate,
    );
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Скопировать / Поделиться',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Текст сформирован для выбранной даты.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await ExportService.copyToClipboard(text);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Скопировано в буфер')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Скопировать'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ExportService.shareText(
                      text,
                      subject: 'Посещаемость',
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Поделиться'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMMM yyyy', 'ru').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studyClass.name),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Скопировать / Поделиться',
            onPressed: () {
              final notifier = context.read<AttendanceNotifier>();
              _showExportSheet(context, notifier);
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Дата посещаемости',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateLabel,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _pickDate,
                      child: const Text('Изменить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Поиск по имени ученика',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: Consumer<AttendanceNotifier>(
              builder: (context, notifier, _) {
                final students = notifier.studentsInClassFiltered(
                  widget.studyClass.id,
                  _searchQuery,
                );
                if (notifier.studentsInClass(widget.studyClass.id).isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_off_rounded,
                    title: 'В классе пока нет учеников',
                    subtitle: 'Добавьте учеников кнопкой ниже',
                  );
                }
                if (students.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Никого не найдено',
                    subtitle:
                        'Попробуйте изменить запрос: «${_searchController.text}»',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88, top: 8),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final status = notifier.statusFor(
                      widget.studyClass.id,
                      _selectedDate,
                      s.id,
                    );
                    return StudentAttendanceTile(
                      student: s,
                      status: status,
                      onStatusChanged: (v) {
                        notifier.setAttendanceStatus(
                          widget.studyClass.id,
                          _selectedDate,
                          s.id,
                          v,
                        );
                      },
                      onDelete: () => _confirmDeleteStudent(context, notifier, s.id, s.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await showAddStudentDialog(context);
          if (name == null || !context.mounted) return;
          if (name.isEmpty) return;
          await context.read<AttendanceNotifier>().addStudent(
                widget.studyClass.id,
                name,
              );
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Ученик'),
      ),
    );
  }

  Future<void> _confirmDeleteStudent(
    BuildContext context,
    AttendanceNotifier notifier,
    String studentId,
    String studentName,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить ученика?'),
        content: Text('Ученик «$studentName» будет удалён из класса.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await notifier.deleteStudent(studentId);
    }
  }
}
