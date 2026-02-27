// ignore_for_file: invalid_runtime_check_with_js_interop_types

import 'dart:async';
import 'package:app/logging_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/widgets.dart';

enum AppLifeEvent { resumed, paused, hidden, visible, detached }

class AppLifecycleService with WidgetsBindingObserver {
  final _controller = StreamController<AppLifeEvent>.broadcast();
  Stream<AppLifeEvent> get events => _controller.stream;

  AppLifecycleService() {
    WidgetsBinding.instance.addObserver(this);

    if (kIsWeb) {
      web.document.onVisibilityChange.listen((_) {
        if (web.document.hidden) {
          _controller.add(AppLifeEvent.hidden);
        } else {
          _controller.add(AppLifeEvent.visible);
        }
      });

      web.window.addEventListener(
        'focus',
        ((web.Event event) {
              _controller.add(AppLifeEvent.resumed);
            })
            as web.EventListener,
      );
      web.window.addEventListener(
        'blur',
        ((web.Event event) {
              _controller.add(AppLifeEvent.paused);
            })
            as web.EventListener,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.add(AppLifeEvent.resumed);
        LoggingService.info(tag: 'AppLifecycleState', 'Resumed');
        break;
      case AppLifecycleState.paused:
        _controller.add(AppLifeEvent.paused);
        LoggingService.info(tag: 'AppLifecycleState', 'Paused');
        break;
      case AppLifecycleState.inactive:
        _controller.add(AppLifeEvent.paused);
        LoggingService.info(tag: 'AppLifecycleState', 'Inactive');
        break;
      case AppLifecycleState.detached:
        _controller.add(AppLifeEvent.detached);
        LoggingService.info(tag: 'AppLifecycleState', 'Detached');
        break;
      case AppLifecycleState.hidden:
        _controller.add(AppLifeEvent.hidden);
        LoggingService.info(tag: 'AppLifecycleState', 'Hidden');
        break;
    }
  }
}
