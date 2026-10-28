import 'package:material_ui/material_ui.dart';
import './layerx_base.dart';

class LayerXWrapper extends StatefulWidget {
  final Widget child;
  const LayerXWrapper({super.key, required this.child});

  @override
  State<LayerXWrapper> createState() => _LayerXWrapperState();
}

class _LayerXWrapperState extends State<LayerXWrapper> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LayerX.isModalActive,
      builder: (context, isActive, _) {
        return PopScope(
          canPop: !isActive,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            LayerX.handleBackPress();
          },
          child: Overlay(
            key: LayerX.overlayKey,
            initialEntries: [
              OverlayEntry(builder: (_) => widget.child),
            ],
          ),
        );
      },
    );
  }
}
