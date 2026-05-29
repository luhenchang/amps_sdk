import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Android PlatformView 封装。
///
/// 在 Android 12 以下，Flutter 默认的 SurfaceProducer 后端在 PlatformView
/// 频繁创建/销毁时可能触发 `Image is already closed` 并导致引擎 abort。
/// 此处强制使用 Hybrid Composition（initExpensiveAndroidView）规避该问题。
Widget buildAmpsAndroidPlatformView({
  required String viewType,
  required Map<String, dynamic> creationParams,
  required ValueChanged<int> onPlatformViewCreated,
  Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
}) {
  final recognizers =
      gestureRecognizers ?? const <Factory<OneSequenceGestureRecognizer>>{};

  return PlatformViewLink(
    viewType: viewType,
    surfaceFactory: (context, controller) {
      return AndroidViewSurface(
        controller: controller as AndroidViewController,
        gestureRecognizers: recognizers,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    },
    onCreatePlatformView: (params) {
      final controller = PlatformViewsService.initExpensiveAndroidView(
        id: params.id,
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onFocus: () => params.onFocusChanged(true),
      );
      controller
        ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
        ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
        ..create();
      return controller;
    },
  );
}
