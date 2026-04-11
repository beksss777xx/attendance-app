import 'package:flutter/material.dart';

import '../models/attendance_status.dart';
import '../models/student.dart';
import 'attendance_status_menu.dart';

class StudentAttendanceTile extends StatelessWidget {
  const StudentAttendanceTile({
    super.key,
    required this.student,
    required this.status,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final Student student;
  final AttendanceStatus? status;
  final ValueChanged<AttendanceStatus?> onStatusChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                  child: Text(
                    _initials(student.name),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    student.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.person_remove_outlined),
                  tooltip: 'Удалить ученика',
                ),
              ],
            ),
            const SizedBox(height: 8),
            AttendanceStatusMenu(
              value: status,
              onChanged: onStatusChanged,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
