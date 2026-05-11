import 'dart:async';

import 'package:finxl/features/sms_detection/domain/entities/detected_sms_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SmsDetectionService {
  SmsDetectionService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel('finxl/sms_detection'),
       _eventChannel =
           eventChannel ?? const EventChannel('finxl/sms_detection/events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  StreamSubscription<dynamic>? _subscription;

  StreamController<DetectedSmsMessage>? _controller;

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<DetectedSmsMessage> get messages {
    _controller ??= StreamController<DetectedSmsMessage>.broadcast(
      onListen: _startNativeStream,
      onCancel: _stopNativeStream,
    );
    return _controller!.stream;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final granted = await _methodChannel.invokeMethod<bool>(
      'requestSmsPermission',
    );
    return granted ?? false;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    final granted = await _methodChannel.invokeMethod<bool>('hasSmsPermission');
    return granted ?? false;
  }

  Future<void> startListening() async {
    if (!isSupported) return;
    await _methodChannel.invokeMethod<void>('startListening');
    _startNativeStream();
  }

  Future<void> stopListening() async {
    if (!isSupported) return;
    await _methodChannel.invokeMethod<void>('stopListening');
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    unawaited(stopListening());
    unawaited(_controller?.close());
    _controller = null;
  }

  void _startNativeStream() {
    if (_subscription != null || !isSupported) return;
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        _controller?.add(DetectedSmsMessage.fromMap(event));
      }
    }, onError: _controller?.addError);
  }

  Future<void> _stopNativeStream() async {
    if (_controller?.hasListener ?? false) return;
    await _subscription?.cancel();
    _subscription = null;
  }
}
