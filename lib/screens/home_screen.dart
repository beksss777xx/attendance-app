import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_notifier.dart';
import '../widgets/add_class_dialog.dart';
import '../widgets/class_card.dart';
import '../widgets/empty_state.dart';
import 'class_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text('Классы'),
        centerTitle: true,
      ),
      body: Consumer<AttendanceNotifier>(
        builder: (context, notifier, _) {
          final list = notifier.classes;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.class_rounded,
              title: 'Пока нет классов',
              subtitle: 'Нажмите «+», чтобы создать первый класс',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final c = list[index];
              return ClassCard(
                studyClass: c,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ClassDetailScreen(studyClass: c),
                    ),
                  );
                },
                onDelete: () => _confirmDeleteClass(context, notifier, c.id, c.name),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await showAddClassDialog(context);
          if (name == null || !context.mounted) return;
          if (name.isEmpty) return;
          await context.read<AttendanceNotifier>().addClass(name);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Класс'),
      ),
    );
  }

  Future<void> _confirmDeleteClass(
    BuildContext context,
    AttendanceNotifier notifier,
    String classId,
    String className,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить класс?'),
        content: Text(
          'Класс «$className» и все связанные ученики и отметки будут удалены без восстановления.',
        ),
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
      await notifier.deleteClass(classId);
    }
  }
}
