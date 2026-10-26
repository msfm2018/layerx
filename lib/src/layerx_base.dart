import 'dart:async';
import 'package:flutter/widgets.dart';

import 'core/bottom_sheet_wrapper.dart';
import 'core/modal_wrapper.dart';
import 'core/toast_wrapper.dart';
import 'core/toast_wrapper_simple.dart';
import 'layerx_wrapper.dart';

class LayerX {
  static final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  static final List<OverlayEntry> modalStack = [];
  static final ValueNotifier<bool> isModalActive = ValueNotifier(false);

  // -------------------- 初始化 --------------------
  static TransitionBuilder init({TransitionBuilder? builder}) {
    return (context, child) {
      if (builder != null) {
        child = builder(context, child);
      }

      return ValueListenableBuilder<bool>(
        valueListenable: isModalActive,
        builder: (context, isActive, _) {
          return PopScope(
            canPop: !isActive,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              handleBackPress();
            },
            child: Overlay(
              key: overlayKey,
              initialEntries: [
                OverlayEntry(builder: (_) => child ?? const SizedBox.shrink()),
              ],
            ),
          );
        },
      );
    };
  }

  static Widget wrapper({required Widget child}) {
    return LayerXWrapper(child: child);
  }

  // -------------------- 工具方法 --------------------
  static OverlayState _getOverlay(BuildContext? context) {
    if (context != null) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }

    final global = overlayKey.currentState;
    if (global != null) return global;

    throw FlutterError(
      'LayerX: No Overlay found.\n'
      '1. Use LayerX.init() in your app builder, or\n'
      '2. Pass context: LayerX.toast("msg", context: context)',
    );
  }

  static bool _useGlobalStack(BuildContext? context) {
    return context == null && overlayKey.currentState != null;
  }

  static Widget _localize(BuildContext? context, Widget child) {
    final ctx = context ?? overlayKey.currentContext;

    if (ctx == null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      );
    }

    return Directionality(
      textDirection: Directionality.of(ctx),
      child: child,
    );
  }

  static void _pushEntry(OverlayEntry entry, {BuildContext? context}) {
    if (_useGlobalStack(context)) {
      modalStack.add(entry);
      overlayKey.currentState?.insert(entry);
      _updateModalState();
    } else {
      _getOverlay(context).insert(entry);
    }
  }

  static void _removeEntry(OverlayEntry entry, {BuildContext? context}) {
    entry.remove();
    if (_useGlobalStack(context)) {
      modalStack.remove(entry);
      _updateModalState();
    }
  }

  static void _updateModalState() {
    isModalActive.value = modalStack.isNotEmpty;
  }

  static void handleBackPress() {
    if (modalStack.isNotEmpty) {
      final last = modalStack.last;
      last.remove();
      modalStack.removeLast();
      _updateModalState();
    }
  }

  // -------------------- 简单按钮（替代 TextButton） --------------------
  static Widget _simpleButton({
    required String text,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF1976D2) : const Color(0x00000000),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primary ? const Color(0xFFFFFFFF) : const Color(0xFF1976D2),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // -------------------- Dialog --------------------
  static Future<bool> confirm(
    String message, {
    BuildContext? context,
    String title = 'Confirm',
    String yesText = 'OK',
    String noText = 'Cancel',
  }) {
    final completer = Completer<bool>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _localize(
        context,
        ModalWrapper(
          onClose: (result) {
            _removeEntry(entry, context: context);
            completer.complete(result as bool? ?? false);
          },
          child: Builder(
            builder: (ctx) => _buildDialog(
              title: title,
              content: Text(message),
              actions: [
                _simpleButton(
                  text: noText,
                  onPressed: () => ModalWrapper.of(ctx)?.dismiss(false),
                ),
                _simpleButton(
                  text: yesText,
                  primary: true,
                  onPressed: () => ModalWrapper.of(ctx)?.dismiss(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  static Future<void> show(
    String message, {
    BuildContext? context,
    String title = 'Confirm',
    String okText = 'OK',
  }) {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _localize(
        context,
        ModalWrapper(
          onClose: (_) {
            _removeEntry(entry, context: context);
            completer.complete();
          },
          child: Builder(
            builder: (ctx) => _buildDialog(
              title: title,
              content: Text(message),
              actions: [
                _simpleButton(
                  text: okText,
                  primary: true,
                  onPressed: () => ModalWrapper.of(ctx)?.dismiss(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  static Future<void> alert(
    String message, {
    BuildContext? context,
    String title = 'Confirm',
    String okText = 'OK',
  }) =>
      show(message, context: context, title: title, okText: okText);

  // 简单 Dialog 容器
  static Widget _buildDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: const TextStyle(fontSize: 15, color: Color(0xFF424242)),
            child: content,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .map((e) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: e,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // -------------------- Input --------------------
  static Future<String?> input({
    BuildContext? context,
    String title = 'Input',
    String hint = 'Please enter something',
  }) {
    final completer = Completer<String?>();
    final controller = TextEditingController();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _localize(
        context,
        ModalWrapper(
          onClose: (result) {
            controller.dispose();
            _removeEntry(entry, context: context);
            completer.complete(result != null ? controller.text : null);
          },
          child: Builder(
            builder: (ctx) => _buildDialog(
              title: title,
              content: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFBDBDBD)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: EditableText(
                  controller: controller,
                  focusNode: FocusNode()..requestFocus(),
                  style:
                      const TextStyle(fontSize: 15, color: Color(0xFF212121)),
                  cursorColor: const Color(0xFF1976D2),
                  backgroundCursorColor: const Color(0xFF1976D2),
                ),
              ),
              actions: [
                _simpleButton(
                  text: 'Cancel',
                  onPressed: () => ModalWrapper.of(ctx)?.dismiss(false),
                ),
                _simpleButton(
                  text: 'OK',
                  primary: true,
                  onPressed: () => ModalWrapper.of(ctx)?.dismiss(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  // -------------------- Custom --------------------
  static Future<T?> custom<T>(Widget child, {BuildContext? context}) {
    final completer = Completer<T?>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper<T>(
        onClose: (result) {
          _removeEntry(entry, context: context);
          completer.complete(result);
        },
        child: child,
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  static void dismiss<T>(BuildContext context, [T? result]) {
    ModalWrapper.of<T>(context)?.dismiss(result);
  }

  // -------------------- BottomSheet / ActionSheet --------------------
  static Future<void> bottomSheet(Widget child, {BuildContext? context}) {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _removeEntry(entry, context: context);
              completer.complete();
            },
            child: Container(color: const Color(0x42000000)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetWrapper(
              onClose: () {
                _removeEntry(entry, context: context);
                completer.complete();
              },
              child: child,
            ),
          ),
        ],
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  static Future<int?> actionSheet({
    required List<String> options,
    BuildContext? context,
  }) {
    final completer = Completer<int?>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _removeEntry(entry, context: context);
              completer.complete(null);
            },
            child: Container(color: const Color(0x42000000)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetWrapper(
              onClose: () {
                _removeEntry(entry, context: context);
                completer.complete(null);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(options.length, (i) {
                  return GestureDetector(
                    onTap: () {
                      _removeEntry(entry, context: context);
                      completer.complete(i);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        options[i],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );

    _pushEntry(entry, context: context);
    return completer.future;
  }

  // -------------------- Loading --------------------
  static OverlayEntry? _loadingEntry;
  static int loadingCount = 0;
  static Timer? _loadingDelayTimer;
  static DateTime? _loadingShownAt;
  static Duration _delay = const Duration(milliseconds: 200);
  static Duration _minShow = const Duration(milliseconds: 400);
  static BuildContext? _lastLoadingContext;

  static void config({Duration? delay, Duration? minShow}) {
    if (delay != null) _delay = delay;
    if (minShow != null) _minShow = minShow;
  }

  static void loading({
    BuildContext? context,
    String message = 'Loading...',
  }) {
    loadingCount++;
    _lastLoadingContext = context;

    if (_loadingEntry != null || _loadingDelayTimer != null) return;

    _loadingDelayTimer = Timer(_delay, () {
      _loadingDelayTimer = null;
      if (loadingCount <= 0) return;

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => Stack(
          children: [
            const ModalBarrier(color: Color(0x42000000)),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xE6000000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 简单转圈（纯 widgets 实现）
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: _SimpleProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      _loadingEntry = entry;
      _loadingShownAt = DateTime.now();
      _pushEntry(entry, context: context);
    });
  }

  static void dismissLoading() {
    if (loadingCount <= 0) return;
    loadingCount--;

    if (loadingCount > 0) return;

    if (_loadingDelayTimer != null) {
      _loadingDelayTimer?.cancel();
      _loadingDelayTimer = null;
      return;
    }

    if (_loadingEntry != null && _loadingShownAt != null) {
      final elapsed = DateTime.now().difference(_loadingShownAt!);
      if (elapsed < _minShow) {
        Future.delayed(_minShow - elapsed, _doRemoveLoading);
        return;
      }
    }
    _doRemoveLoading();
  }

  static void _doRemoveLoading() {
    if (_loadingEntry != null) {
      _removeEntry(_loadingEntry!, context: _lastLoadingContext);
      _loadingEntry = null;
      _loadingShownAt = null;
    }
  }

  static Future<T?> wrapLoading<T>(
    FutureOr<T> Function() task, {
    BuildContext? context,
    String message = 'Loading...',
    Duration? timeout,
    Function(Object error)? onError,
  }) async {
    loading(context: context, message: message);
    try {
      Future<T> future = Future.value(task());
      if (timeout != null) future = future.timeout(timeout);
      return await future;
    } catch (e) {
      onError?.call(e);
      return null;
    } finally {
      dismissLoading();
    }
  }

  // -------------------- Progress --------------------
  static OverlayEntry? _progressEntry;

  static void progress(double value, {BuildContext? context}) {
    _progressEntry?.remove();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          const ModalBarrier(color: Color(0x42000000)),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _SimpleProgressIndicator(value: value),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    _progressEntry = entry;
    _pushEntry(entry, context: context);
  }

  static void dismissProgress({BuildContext? context}) {
    _progressEntry?.remove();
    _progressEntry = null;
  }

  // -------------------- Toast --------------------
  static void toast(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 2),
    bool fromBottom = true,
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ToastWrapper(
        duration: duration,
        fromBottom: fromBottom,
        onEnd: () => entry.remove(),
        child: Align(
          alignment:
              fromBottom ? Alignment.bottomCenter : const Alignment(0, 0.7),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: fromBottom ? 50 : 0,
              left: 20,
              right: 20,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xE6000000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    _getOverlay(context).insert(entry);
  }

  static void toastSimple(String message, {BuildContext? context}) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ToastWrapperSimple(
        onEnd: () => entry.remove(),
        child: Align(
          alignment: const Alignment(0, 0.7),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xE6000000),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      ),
    );

    _getOverlay(context).insert(entry);
  }

  static void notification({
    required String title,
    required String message,
    BuildContext? context,
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ToastWrapper(
        onEnd: () => entry.remove(),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    _getOverlay(context).insert(entry);
  }

  static void dismissAll() {
    while (modalStack.isNotEmpty) {
      final entry = modalStack.removeLast();
      entry.remove();
    }
    _updateModalState();
  }
}

/// 简单的进度指示器（纯 widgets 实现，不依赖 Material）
class _SimpleProgressIndicator extends StatefulWidget {
  final double? value;
  const _SimpleProgressIndicator({this.value});

  @override
  State<_SimpleProgressIndicator> createState() =>
      _SimpleProgressIndicatorState();
}

class _SimpleProgressIndicatorState extends State<_SimpleProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _ProgressPainter(
            progress: widget.value ?? _controller.value,
            isIndeterminate: widget.value == null,
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final bool isIndeterminate;

  _ProgressPainter({required this.progress, required this.isIndeterminate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    if (isIndeterminate) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        progress * 2 * 3.14159,
        1.5,
        false,
        paint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708, // -90度
        progress * 2 * 3.14159,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) => true;
}
