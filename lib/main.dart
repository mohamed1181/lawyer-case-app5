import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/case_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/case_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = CaseRepository();
  await repository.init(); // تهيئة Hive وفتح قاعدة البيانات المحلية

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final CaseRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseProvider(repository),
      child: MaterialApp(
        title: 'إدارة القضايا القانونية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        locale: const Locale('ar'),
        // دعم الاتجاه من اليمين لليسار لكامل التطبيق
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
