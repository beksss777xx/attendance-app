enum AttendanceStatus {
  present,
  absent,
  late,
}

extension AttendanceStatusLabels on AttendanceStatus {
  String get labelRu => switch (this) {
        AttendanceStatus.present => 'Присутствует',
        AttendanceStatus.absent => 'Отсутствует',
        AttendanceStatus.late => 'Опоздал',
      };
}

AttendanceStatus? parseAttendanceStatus(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final v in AttendanceStatus.values) {
    if (v.name == raw) return v;
  }
  return null;
}
