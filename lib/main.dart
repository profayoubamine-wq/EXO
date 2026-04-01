import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/data_service.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.init();
  runApp(const ExoAyoubApp());
}

class ExoAyoubApp extends StatelessWidget {
  const ExoAyoubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'EXO Ayoub',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
