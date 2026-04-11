import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/app_data.dart';
import '../models/attendance_status.dart';
import '../models/student.dart';
import '../models/study_class.dart';
import '../services/local_storage_service.dart';

class AttendanceNotifier extends ChangeNotifier {
  AttendanceNotifier(this._storage);

  final LocalStorageService _storage;

  final List<StudyClass> _classes = [];
  final List<Student> _students = [];
  final Map<String, Map<String, AttendanceStatus?>> _attendance = {};

  List<StudyClass> get classes {
    final copy = List<StudyClass>.from(_classes);
    copy.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(copy);
  }

  List<Student> studentsInClass(String classId) {
    final list = _students.where((s) => s.classId == classId).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<Student> studentsInClassFiltered(String classId, String query) {
    final q = query.trim().toLowerCase();
    final base = studentsInClass(classId);
    if (q.isEmpty) return base;
    return base.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  String dateKey(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String attendanceMapKey(String classId, DateTime date) =>
      '$classId|${dateKey(date)}';

  AttendanceStatus? statusFor(String classId, DateTime date, String studentId) {
    final key = attendanceMapKey(classId, date);
    return _attendance[key]?[studentId];
  }

  Future<void> loadFromStorage() async {
    final data = await _storage.load();
    _classes
      ..clear()
      ..addAll(data.classes);
    _students
      ..clear()
      ..addAll(data.students);
    _attendance
      ..clear()
      ..addAll(data.attendance);
    notifyListeners();
  }

  Future<void> _persist() async {
    final data = AppData(
      classes: List.from(_classes),
      students: List.from(_students),
      attendance: _attendance.map(
        (k, v) => MapEntry(k, Map<String, AttendanceStatus?>.from(v)),
      ),
    );
    await _storage.save(data);
  }

  String _newId() {
    final r = Random();
    return '${DateTime.now().microsecondsSinceEpoch}_${r.nextInt(1 << 30)}';
  }

  Future<void> addClass(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _classes.add(StudyClass(id: _newId(), name: trimmed));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteClass(String classId) async {
    _classes.removeWhere((c) => c.id == classId);
    _students.removeWhere((s) => s.classId == classId);
    final keysToRemove =
        _attendance.keys.where((k) => k.startsWith('$classId|')).toList();
    for (final k in keysToRemove) {
      _attendance.remove(k);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> addStudent(String classId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (!_classes.any((c) => c.id == classId)) return;
    _students.add(Student(id: _newId(), classId: classId, name: trimmed));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteStudent(String studentId) async {
    _students.removeWhere((s) => s.id == studentId);
    for (final inner in _attendance.values) {
      inner.remove(studentId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> setAttendanceStatus(
    String classId,
    DateTime date,
    String studentId,
    AttendanceStatus? status,
  ) async {
    final key = attendanceMapKey(classId, date);
    _attendance.putIfAbsent(key, () => {});
    if (status == null) {
      _attendance[key]!.remove(studentId);
      if (_attendance[key]!.isEmpty) {
        _attendance.remove(key);
      }
    } else {
      _attendance[key]![studentId] = status;
    }
    await _persist();
    notifyListeners();
  }

  String buildExportText({
    required String classId,
    required DateTime date,
  }) {
    final match = _classes.where((c) => c.id == classId);
    final className = match.isEmpty ? 'Класс' : match.first.name;
    final students = studentsInClass(classId);
    final buf = StringBuffer();
    buf.writeln('Посещаемость: $className');
    buf.writeln('Дата: ${DateFormat('dd.MM.yyyy').format(date)}');
    buf.writeln();
    if (students.isEmpty) {
      buf.writeln('Нет учеников в классе.');
      return buf.toString();
    }
    for (final s in students) {
      final st = statusFor(classId, date, s.id);
      final label = st?.labelRu ?? 'Не отмечено';
      buf.writeln('• ${s.name} — $label');
    }
    return buf.toString().trimRight();
  }
}
