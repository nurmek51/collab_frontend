import 'package:flutter/widgets.dart';

/// No-op debug overlay. Kept for compatibility with any imports,
/// but simply returns the child without adding UI or functionality.
class DebugOverlay extends StatelessWidget {
  final Widget child;

  const DebugOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => child;
}
