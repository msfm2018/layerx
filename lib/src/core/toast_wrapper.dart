import 'dart:async';
import 'package:material_ui/material_ui.dart';

class ToastWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnd;
  final Duration duration;
  final bool fromBottom;

  const ToastWrapper(
      {super.key,
      required this.child,
      required this.onEnd,
      this.duration = const Duration(seconds: 2),
      this.fromBottom = true});

  @override
  State<ToastWrapper> createState() => _ToastWrapperState();
}

class _ToastWrapperState extends State<ToastWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _offsetAnimation = Tween<Offset>(
      begin: widget.fromBottom ? const Offset(0, 0.3) : const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // 自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onEnd();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _controller, child: widget.child),
    );
  }
}
