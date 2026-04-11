import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance_app/main.dart';
import 'package:attendance_app/providers/attendance_notifier.dart';
import 'package:attendance_app/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Отображается экран классов', (WidgetTester tester) async {
    final storage = LocalStorageService();
    final notifier = AttendanceNotifier(storage);
    await notifier.loadFromStorage();

    await tester.pumpWidget(
      ChangeNotifierProvider<AttendanceNotifier>.value(
        value: notifier,
        child: const AttendanceApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Классы'), findsOneWidget);
  });
}
