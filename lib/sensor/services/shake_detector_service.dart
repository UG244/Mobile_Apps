import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Service untuk mendeteksi gerakan shake (guncangan) menggunakan Accelerometer.
///
/// Cara pakai:
/// ```dart
/// final detector = ShakeDetectorService(onShake: () { /* refresh */ });
/// detector.startListening();
/// // ...saat dispose:
/// detector.stopListening();
/// ```
class ShakeDetectorService {
  ShakeDetectorService({
    required this.onShake,
    this.shakeThreshold = 15.0,
    this.minTimeBetweenShakes = const Duration(milliseconds: 1200),
  });

  /// Callback dipanggil setiap kali shake terdeteksi.
  final VoidCallback onShake;

  /// Nilai minimum akselerasi (m/s²) yang dianggap sebagai shake.
  /// Default 15.0 — cukup sensitif tanpa terlalu mudah trigger.
  final double shakeThreshold;

  /// Jeda minimum antar shake agar tidak trigger berulang kali.
  final Duration minTimeBetweenShakes;

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShakeTime = DateTime(0);

  /// Mulai mendengarkan sensor accelerometer.
  void startListening() {
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(_onAccelEvent);
  }

  /// Berhenti mendengarkan — panggil saat widget di-dispose.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onAccelEvent(AccelerometerEvent event) {
    // Hitung magnitude vektor gaya: √(x² + y² + z²)
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Gravitasi bumi ≈ 9.8 m/s² — kurangi agar hanya gerakan tambahan
    final acceleration = magnitude - 9.8;

    if (acceleration > shakeThreshold) {
      final now = DateTime.now();
      final timeSinceLast = now.difference(_lastShakeTime);

      if (timeSinceLast >= minTimeBetweenShakes) {
        _lastShakeTime = now;
        onShake();
      }
    }
  }
}

// Alias agar tidak perlu import flutter/foundation
typedef VoidCallback = void Function();
