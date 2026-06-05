import 'package:flutter/material.dart';
import './layerx_base.dart';

/// A wrapper widget that initializes LayerX.
///
/// Use this when you prefer widget composition over `MaterialApp.builder`.
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
          child: Material(
            color: Colors.transparent,
            child: Overlay(
              key: LayerX.overlayKey,
              initialEntries: [OverlayEntry(builder: (_) => widget.child)],
            ),
          ),
        );
      },
    );
  }
}
