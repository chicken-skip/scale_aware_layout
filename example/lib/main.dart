import 'package:flutter/material.dart';
import 'package:scale_aware_layout/scale_aware_layout.dart';

void main() => runApp(const ExampleApp());

/// The "Text Scale Torture Chamber" demo app.
///
/// Drag the slider to raise the text scale (as a user would in their OS
/// accessibility settings) and compare plain Flutter layouts (which overflow)
/// with the same content wrapped in `scale_aware_layout` (which reflows).
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Scale Torture Chamber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const _TortureChamber(),
    );
  }
}

class _TortureChamber extends StatefulWidget {
  const _TortureChamber();

  @override
  State<_TortureChamber> createState() => _TortureChamberState();
}

class _TortureChamberState extends State<_TortureChamber> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Scale Torture Chamber')),
      body: Column(
        children: [
          _ScaleControls(
            scale: _scale,
            onChanged: (v) => setState(() => _scale = v),
          ),
          const Divider(height: 1),
          Expanded(
            // Apply the chosen text scale to the whole demo subtree, exactly as
            // the operating system would for the entire app.
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_scale),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _Comparison(label: 'Settings row', child: _SettingsRow()),
                  _Comparison(label: 'Product card', child: _ProductCard()),
                  _Comparison(label: 'Profile header', child: _ProfileHeader()),
                  _Comparison(
                    label: 'Checkout summary',
                    child: _CheckoutSummary(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleControls extends StatelessWidget {
  const _ScaleControls({required this.scale, required this.onChanged});

  final double scale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.text_fields),
          Expanded(
            child: Slider(
              value: scale,
              min: 1.0,
              max: 2.5,
              divisions: 30,
              label: '${(scale * 100).round()}%',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${(scale * 100).round()}%',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the same [child] twice: once as plain Flutter, once "adaptive".
///
/// Each sample reads an inherited `adaptive` flag via [_Adaptive] to decide
/// whether to lay itself out with a [Row] or an [AdaptiveRowColumn].
class _Comparison extends StatelessWidget {
  const _Comparison({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _Tag(text: 'Plain Flutter', color: Color(0xFFB3261E)),
            const SizedBox(height: 4),
            _Adaptive(adaptive: false, child: child),
            const SizedBox(height: 12),
            const _Tag(text: 'scale_aware_layout', color: Color(0xFF146C2E)),
            const SizedBox(height: 4),
            _Adaptive(adaptive: true, child: child),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

/// Inherited flag telling a sample whether to lay out adaptively.
class _Adaptive extends InheritedWidget {
  const _Adaptive({required this.adaptive, required super.child});

  final bool adaptive;

  static bool of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<_Adaptive>();
    return widget?.adaptive ?? false;
  }

  @override
  bool updateShouldNotify(_Adaptive oldWidget) =>
      adaptive != oldWidget.adaptive;
}

/// Lays [children] out as a plain [Row] or an [AdaptiveRowColumn] depending on
/// the inherited [_Adaptive] flag, so both variants share identical content.
class _Sample extends StatelessWidget {
  const _Sample({required this.children});

  static const double _spacing = 12;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (_Adaptive.of(context)) {
      return AdaptiveRowColumn(
        spacing: _spacing,
        rowCrossAxisAlignment: CrossAxisAlignment.center,
        columnCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: _spacing),
          children[i],
        ],
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow();

  @override
  Widget build(BuildContext context) {
    return const _Sample(
      children: [
        Icon(Icons.notifications_outlined),
        Text('Push notifications for new messages and updates'),
        Icon(Icons.chevron_right),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    return _Sample(
      children: [
        Container(width: 48, height: 48, color: const Color(0xFFD0BCFF)),
        const Text('Ergonomic Wireless Keyboard'),
        const Text(r'$129'),
        FilledButton(onPressed: () {}, child: const Text('Add to cart')),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return _Sample(
      children: [
        const CircleAvatar(child: Text('AB')),
        const Text('Alex Bergström'),
        OutlinedButton(onPressed: () {}, child: const Text('Follow')),
      ],
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary();

  @override
  Widget build(BuildContext context) {
    return const _Sample(
      children: [
        Text('Estimated total including taxes and shipping'),
        Text(r'$1,284.00'),
      ],
    );
  }
}
