import 'package:flutter/widgets.dart';

class ToastWrapperSimple extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnd;

  const ToastWrapperSimple(
      {super.key, required this.child, required this.onEnd});

  @override
  State<ToastWrapperSimple> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<ToastWrapperSimple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        await _controller.reverse();
        widget.onEnd();
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _controller, child: widget.child);
}
