import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Skeleton example app. The full "Text Scale Torture Chamber" demo is built
/// in milestone M5.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'scale_aware_layout example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(title: const Text('scale_aware_layout')),
        body: const Center(
          child: Text('Text Scale Torture Chamber — coming in M5'),
        ),
      ),
    );
  }
}
