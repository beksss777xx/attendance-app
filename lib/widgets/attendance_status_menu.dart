import 'package:flutter/material.dart';

import '../models/attendance_status.dart';

class AttendanceStatusMenu extends StatelessWidget {
  const AttendanceStatusMenu({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AttendanceStatus? value;
  final ValueChanged<AttendanceStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<AttendanceStatus?>(
      tooltip: 'Статус посещаемости',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<AttendanceStatus?>(
          value: null,
          child: Text(
            'Не отмечено',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const PopupMenuDivider(),
        ...AttendanceStatus.values.map(
          (s) => PopupMenuItem<AttendanceStatus?>(
            value: s,
            child: Text(s.labelRu),
          ),
        ),
      ],
      child: InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                value?.labelRu ?? 'Выберите статус',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
