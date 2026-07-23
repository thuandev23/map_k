import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'features/map/presentation/screens/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://examplePublicKey@o0.ingest.sentry.io/0';
      options.tracesSampleRate = 1.0;
      options.environment = 'development';
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: MapKApp(),
      ),
    ),
  );
}

class MapKApp extends StatelessWidget {
  const MapKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map K',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
