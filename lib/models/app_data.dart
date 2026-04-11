import 'attendance_status.dart';
import 'student.dart';
import 'study_class.dart';

class AppData {
  const AppData({
    required this.classes,
    required this.students,
    required this.attendance,
  });

  final List<StudyClass> classes;
  final List<Student> students;
  final Map<String, Map<String, AttendanceStatus?>> attendance;

  Map<String, dynamic> toJson() {
    final attendanceJson = <String, dynamic>{};
    for (final e in attendance.entries) {
      final inner = <String, dynamic>{};
      for (final s in e.value.entries) {
        inner[s.key] = s.value?.name;
      }
      attendanceJson[e.key] = inner;
    }
    return {
      'classes': classes.map((c) => c.toJson()).toList(),
      'students': students.map((s) => s.toJson()).toList(),
      'attendance': attendanceJson,
    };
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final classes = (json['classes'] as List<dynamic>? ?? [])
        .map((e) => StudyClass.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final students = (json['students'] as List<dynamic>? ?? [])
        .map((e) => Student.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final rawAttendance =
        Map<String, dynamic>.from(json['attendance'] as Map? ?? {});
    final attendance = <String, Map<String, AttendanceStatus?>>{};
    for (final outer in rawAttendance.entries) {
      final innerMap = Map<String, dynamic>.from(outer.value as Map);
      final inner = <String, AttendanceStatus?>{};
      for (final s in innerMap.entries) {
        inner[s.key] = parseAttendanceStatus(s.value as String?);
      }
      attendance[outer.key] = inner;
    }
    return AppData(
      classes: classes,
      students: students,
      attendance: attendance,
    );
  }

  static AppData empty() => AppData(
        classes: [],
        students: [],
        attendance: {},
      );
}
