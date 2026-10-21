import 'package:material_ui/material_ui.dart';

class ModalWrapper<T> extends StatefulWidget {
  final Widget child;
  final ValueChanged<T?> onClose; // 改成泛型

  const ModalWrapper({super.key, required this.child, required this.onClose});

  static ModalWrapperState<T>? of<T>(BuildContext context) {
    return context.findAncestorStateOfType<ModalWrapperState<T>>();
  }

  @override
  State<ModalWrapper<T>> createState() => ModalWrapperState<T>();
}

class ModalWrapperState<T> extends State<ModalWrapper<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..forward();
  }

  void dismiss(T? result) async {
    await _controller.reverse();
    widget.onClose(result);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Container(
              color: Colors.black.withValues(alpha: .4 * _controller.value)),
        ),
        Center(
          child: ScaleTransition(
            scale:
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
            child: FadeTransition(opacity: _controller, child: widget.child),
          ),
        ),
      ],
    );
  }
}
