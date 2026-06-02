import 'dart:async';

import 'package:flutter/material.dart';

import 'core/bottom_sheet_wrapper.dart';
import 'core/modal_wrapper.dart';
import 'core/toast_wrapper.dart';
import 'core/toast_wrapper_simple.dart';

/// A lightweight yet powerful overlay and dialog management system for Flutter.
///
/// LayerX provides a unified API for:
/// - Dialogs (alert, confirm, input, custom)
/// - Toasts & notifications
/// - Bottom sheets & action sheets
/// - Loading & progress indicators
///
/// It is built on top of [Overlay] and manages a global modal stack,
/// enabling advanced UI control without requiring a BuildContext.
class LayerX {
  static final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  static final List<OverlayEntry> _modalStack = [];

  static final ValueNotifier<bool> _isModalActive = ValueNotifier(false);

  /// Initializes LayerX.
  ///
  /// Must be added to `MaterialApp.builder`.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(
  ///   builder: LayerX.init(),
  /// )
  /// ```
  ///
  /// This enables:
  /// - Global overlay access
  /// - Back button interception for modals
  /// - Modal stack management
  static TransitionBuilder init() {
    return (context, child) {
      return ValueListenableBuilder<bool>(
        valueListenable: _isModalActive,
        builder: (context, isActive, _) {
          return PopScope(
            canPop: !isActive,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _handleBackPress();
            },
            child: Material(
              color: Colors.transparent,
              child: Overlay(
                key: _overlayKey,
                initialEntries: [OverlayEntry(builder: (_) => child ?? const SizedBox.shrink())],
              ),
            ),
          );
        },
      );
    };
  }

  /// ==================== 核心栈操作 ====================
  static void _pushEntry(OverlayEntry entry) {
    _modalStack.add(entry);
    _overlayKey.currentState?.insert(entry);
    _updateModalState();
  }

  static void _removeEntry(OverlayEntry entry) {
    entry.remove();
    _modalStack.remove(entry);
    _updateModalState();
  }

  static void _updateModalState() {
    _isModalActive.value = _modalStack.isNotEmpty;
  }

  static void _handleBackPress() {
    if (_modalStack.isNotEmpty) {
      final last = _modalStack.last;
      last.remove();
      _modalStack.removeLast();
      _updateModalState();
    }
  }

  /// ==================== Dialog ====================
  /// Shows a confirmation dialog.
  ///
  /// Returns `true` if confirmed, `false` if cancelled.
  ///
  /// Example:
  /// ```dart
  /// final result = await LayerX.confirm("Are you sure?");
  /// ```
  static Future<bool> confirm(String message, {String title = 'Confirm', String yesText = 'OK', String noText = 'Cancel'}) {
    final completer = Completer<bool>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper(
        onClose: (result) {
          _removeEntry(entry);
          completer.complete(result as FutureOr<bool>?);
        },
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(false), child: Text(noText)),
              TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(true), child: Text(yesText)),
            ],
          ),
        ),
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// Shows a simple alert dialog with a single confirmation button.
  ///
  /// Example:
  /// ```dart
  /// await LayerX.show("Operation completed");
  /// ```
  static Future<void> show(String message, {String title = 'Confirm', String okText = 'OK'}) {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper(
        onClose: (_) {
          _removeEntry(entry);
          completer.complete();
        },
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(true), child: Text(okText))],
          ),
        ),
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// ==================== Input ====================
  /// Shows an input dialog.
  ///
  /// Returns the input text if confirmed, or `null` if cancelled.
  ///
  /// Example:
  /// ```dart
  /// final text = await LayerX.input();
  /// ```
  static Future<String?> input({String title = 'Input', String hint = 'Please enter something'}) {
    final completer = Completer<String?>();
    final controller = TextEditingController();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper(
        onClose: (result) {
          controller.dispose();
          _removeEntry(entry);
          completer.complete(result != null ? controller.text : null);
        },
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: hint),
            ),
            actions: [
              TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(false), child: const Text('cancel')),
              TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(true), child: const Text('ok')),
            ],
          ),
        ),
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// ==================== Custom ====================
  /// Shows a fully custom widget as a modal.
  ///
  /// The result can be returned via [dismiss].
  ///
  /// Example:
  /// ```dart
  /// final result = await LayerX.custom<String>(
  ///   YourWidget(),
  /// );
  /// ```
  static Future<T?> custom<T>(Widget child) {
    final completer = Completer<T?>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper<T>(
        onClose: (result) {
          _removeEntry(entry);
          completer.complete(result);
        },
        child: child,
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// Dismisses the current modal and optionally returns a result.
  ///
  /// Example:
  /// ```dart
  /// LayerX.dismiss(context, "done");
  /// ```
  static void dismiss<T>(BuildContext context, [T? result]) {
    ModalWrapper.of<T>(context)?.dismiss(result);
  }

  /// ==================== BottomSheet ====================
  /// Shows a bottom sheet.
  ///
  /// Tap outside to dismiss.
  ///
  /// Example:
  /// ```dart
  /// await LayerX.bottomSheet(MyWidget());
  /// ```
  static Future<void> bottomSheet(Widget child) {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _removeEntry(entry);
              completer.complete();
            },
            child: Container(color: Colors.black26),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetWrapper(
              onClose: () {
                _removeEntry(entry);
                completer.complete();
              },
              child: child,
            ),
          ),
        ],
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// ==================== ActionSheet ====================
  /// Shows an action sheet with selectable options.
  ///
  /// Returns the selected index, or `null` if dismissed.
  ///
  /// Example:
  /// ```dart
  /// final index = await LayerX.actionSheet(options: ["A", "B"]);
  /// ```
  static Future<int?> actionSheet({required List<String> options}) {
    final completer = Completer<int?>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              _removeEntry(entry);
              completer.complete(null);
            },
            child: Container(color: Colors.black26),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetWrapper(
              onClose: () {
                _removeEntry(entry);
                completer.complete(null);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(options.length, (i) {
                    return ListTile(
                      title: Center(child: Text(options[i])),
                      onTap: () {
                        _removeEntry(entry);
                        completer.complete(i);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// Wraps a task with a loading indicator.
  ///
  /// Automatically shows and dismisses loading.
  ///
  /// Example:
  /// ```dart
  /// await LayerX.wrapLoading(() async {
  ///   await fetchData();
  /// });
  /// ```
  static Future<T?> wrapLoading<T>(FutureOr<T> Function() task, {String message = 'Loading...', Duration? timeout, Function(Object error)? onError}) async {
    loading(message: message);

    try {
      Future<T> future = Future<T>.value(task());

      if (timeout != null) {
        future = future.timeout(timeout);
      }

      return await future;
    } catch (e) {
      onError?.call(e);
      return null;
    } finally {
      dismissLoading();
    }
  }

  /// Configures global loading behavior.
  ///
  /// [delay]: delay before showing loading
  /// [minShow]: minimum display duration
  static void config({Duration? delay, Duration? minShow}) {
    if (delay != null) _delay = delay;
    if (minShow != null) _minShow = minShow;
  }

  static OverlayEntry? _loadingEntry;
  static int loadingCount = 0;

  static Timer? _loadingDelayTimer;
  static DateTime? _loadingShownAt;

  static Duration _delay = Duration(milliseconds: 200);
  static Duration _minShow = Duration(milliseconds: 400);

  /// Shows a loading indicator.
  ///
  /// Supports multiple concurrent calls (reference counting).
  static void loading({String message = 'Loading...'}) {
    loadingCount++;

    // Already showing → just increase reference count
    if (_loadingEntry != null) return;

    // Already waiting to show → do not create again
    if (_loadingDelayTimer != null) return;

    _loadingDelayTimer = Timer(_delay, () {
      _loadingDelayTimer = null;

      // If dismissed during delay → do not show
      if (loadingCount <= 0) return;

      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (_) => Stack(
          children: [
            const ModalBarrier(color: Colors.black26),
            Center(
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 12),
                      Text(message, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      _loadingEntry = entry;
      _loadingShownAt = DateTime.now();

      _pushEntry(entry);
    });
  }

  /// Dismisses the loading indicator.
  ///
  /// Will only disappear when all loading calls are completed.
  static void dismissLoading() {
    if (loadingCount <= 0) return;

    loadingCount--;

    // 还有任务 → 不关
    if (loadingCount > 0) return;

    // 还没显示（在 delay 阶段）→ 直接Cancel
    if (_loadingDelayTimer != null) {
      _loadingDelayTimer?.cancel();
      _loadingDelayTimer = null;
      return;
    }

    // 已经显示 → 需要保证最小展示时间
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
      _removeEntry(_loadingEntry!);
      _loadingEntry = null;
      _loadingShownAt = null;
    }
  }

  /// Alias of [show] with clearer semantics.
  ///
  /// Used for explicit alert dialogs.
  static Future<void> alert(String message, {String title = 'Confirm', String okText = 'OK'}) {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ModalWrapper(
        onClose: (_) {
          _removeEntry(entry);
          completer.complete();
        },
        child: Builder(
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [TextButton(onPressed: () => ModalWrapper.of(context)?.dismiss(true), child: Text(okText))],
          ),
        ),
      ),
    );

    _pushEntry(entry);
    return completer.future;
  }

  /// ==================== Progress ====================

  static OverlayEntry? _progressEntry;

  /// Shows a progress indicator with a given value (0.0 - 1.0).
  ///
  /// Example:
  /// ```dart
  /// LayerX.progress(0.5);
  /// ```
  static void progress(double value) {
    if (_progressEntry != null) {
      _removeEntry(_progressEntry!);
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          const ModalBarrier(color: Colors.black26),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: value),
                    const SizedBox(height: 12),
                    Text('${(value * 100).toInt()}%'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    _progressEntry = entry;
    _pushEntry(entry);
  }

  /// Dismisses the progress indicator.
  static void dismissProgress() {
    if (_progressEntry != null) {
      _removeEntry(_progressEntry!);
      _progressEntry = null;
    }
  }

  /// Shows a top notification message.
  ///
  /// Automatically dismisses after animation.
  ///
  /// Example:
  /// ```dart
  /// LayerX.notification(title: "Success", message: "Done");
  /// ```
  static void notification({required String title, required String message}) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ToastWrapper(
        onEnd: () => _removeEntry(entry),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Card(
              child: ListTile(title: Text(title), subtitle: Text(message)),
            ),
          ),
        ),
      ),
    );
    _pushEntry(entry);
  }

  /// ==================== Toast ====================
  /// Shows a simple centered toast (legacy style).
  ///
  /// This is a lightweight version without advanced animation.
  static void toastSimple(String message) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ToastWrapperSimple(
        onEnd: () => entry.remove(),
        child: Align(
          alignment: const Alignment(0, 0.7),
          child: Card(
            color: Colors.black87,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    _overlayKey.currentState?.insert(entry);
  }

  // ==================== Toast ====================
  /// Shows a toast message.
  ///
  /// [duration]: display duration
  /// [fromBottom]: whether to animate from bottom or center
  ///
  /// Example:
  /// ```dart
  /// LayerX.toast("Hello");
  /// ```
  static void toast(
    String message, {
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
          alignment: fromBottom ? Alignment.bottomCenter : const Alignment(0, 0.7),
          child: Padding(
            padding: EdgeInsets.only(bottom: fromBottom ? 50 : 0, left: 20, right: 20),
            child: Material(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _overlayKey.currentState?.insert(entry);
  }

  /// Dismisses all active modals in the stack.
  static void dismissAll() {
    while (_modalStack.isNotEmpty) {
      final entry = _modalStack.removeLast();
      entry.remove();
    }
    _updateModalState();
  }
}
