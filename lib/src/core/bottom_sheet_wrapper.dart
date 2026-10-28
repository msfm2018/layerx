import 'dart:async';
import 'package:material_ui/material_ui.dart';

class BottomSheetWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;

  const BottomSheetWrapper(
      {super.key, required this.child, required this.onClose});

  @override
  State<BottomSheetWrapper> createState() => _BottomSheetWrapperState();
}

class _BottomSheetWrapperState extends State<BottomSheetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _offset = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> close() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: widget.child,
      ),
    );
  }
}
