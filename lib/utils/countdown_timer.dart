import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CountdownState { notStarted, active, paused, ended }

/// A reusable class that keeps track of a decrementing timer.
class CountdownTimer extends ChangeNotifier {
  final int _countdownTime;
  late var timeLeft = _countdownTime;
  var _countdownState = CountdownState.notStarted;
  Timer? _timer;

  /// Create a countdown timer with specified duration in seconds
  CountdownTimer([this._countdownTime = 5]);

  /// Check if the countdown is complete
  bool get isComplete => _countdownState == CountdownState.ended;

  /// Check if the countdown is active (running)
  bool get isActive => _countdownState == CountdownState.active;

  /// Check if the countdown is paused
  bool get isPaused => _countdownState == CountdownState.paused;

  /// Check if the countdown hasn't started yet
  bool get isNotStarted => _countdownState == CountdownState.notStarted;

  /// Get the current state of the countdown
  CountdownState get state => _countdownState;

  /// Get the initial countdown time
  int get initialTime => _countdownTime;

  /// Get the progress as a percentage (0.0 to 1.0)
  double get progress {
    if (_countdownTime == 0) return 1.0;
    return ((_countdownTime - timeLeft) / _countdownTime).clamp(0.0, 1.0);
  }

  /// Get the remaining progress as a percentage (1.0 to 0.0)
  double get remainingProgress {
    if (_countdownTime == 0) return 0.0;
    return (timeLeft / _countdownTime).clamp(0.0, 1.0);
  }

  /// Start the countdown timer
  void start() {
    if (kDebugMode) {
      print('CountdownTimer: Starting countdown from $_countdownTime seconds');
    }

    timeLeft = _countdownTime;
    _startTimer();
    _countdownState = CountdownState.active;
    notifyListeners();
  }

  /// Resume the countdown timer (if paused)
  void resume() {
    if (_countdownState != CountdownState.paused) {
      if (kDebugMode) {
        print('CountdownTimer: Cannot resume - timer is not paused (current state: $_countdownState)');
      }
      return;
    }

    if (kDebugMode) {
      print('CountdownTimer: Resuming countdown with $timeLeft seconds left');
    }

    _startTimer();
    _countdownState = CountdownState.active;
    notifyListeners();
  }

  /// Pause the countdown timer (if active)
  void pause() {
    if (_countdownState != CountdownState.active) {
      if (kDebugMode) {
        print('CountdownTimer: Cannot pause - timer is not active (current state: $_countdownState)');
      }
      return;
    }

    if (kDebugMode) {
      print('CountdownTimer: Pausing countdown with $timeLeft seconds left');
    }

    _timer?.cancel();
    _countdownState = CountdownState.paused;
    notifyListeners();
  }

  /// Stop and reset the countdown timer
  void stop() {
    if (kDebugMode) {
      print('CountdownTimer: Stopping and resetting countdown');
    }

    _timer?.cancel();
    _countdownState = CountdownState.notStarted;
    timeLeft = _countdownTime;
    notifyListeners();
  }

  /// Add time to the current countdown
  void addTime(int seconds) {
    if (seconds <= 0) return;

    timeLeft += seconds;
    if (kDebugMode) {
      print('CountdownTimer: Added $seconds seconds, new time left: $timeLeft');
    }
    notifyListeners();
  }

  /// Subtract time from the current countdown
  void subtractTime(int seconds) {
    if (seconds <= 0) return;

    timeLeft = (timeLeft - seconds).clamp(0, timeLeft);
    if (kDebugMode) {
      print('CountdownTimer: Subtracted $seconds seconds, new time left: $timeLeft');
    }

    if (timeLeft == 0 && _countdownState == CountdownState.active) {
      _onCountdownComplete();
    } else {
      notifyListeners();
    }
  }

  /// Internal method to start the timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;

      if (kDebugMode && timeLeft % 5 == 0) {
        print('CountdownTimer: $timeLeft seconds remaining');
      }

      if (timeLeft <= 0) {
        _onCountdownComplete();
      } else {
        notifyListeners();
      }
    });
  }

  /// Handle countdown completion
  void _onCountdownComplete() {
    if (kDebugMode) {
      print('CountdownTimer: Countdown completed!');
    }

    _countdownState = CountdownState.ended;
    timeLeft = 0;
    _timer?.cancel();
    notifyListeners();
  }

  /// Format time as MM:SS
  String get formattedTime {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format time as a simple seconds string
  String get formattedTimeSimple {
    if (timeLeft <= 0) return '0';
    return timeLeft.toString();
  }

  /// Get debug information about the timer
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialTime': _countdownTime,
      'timeLeft': timeLeft,
      'state': _countdownState.toString(),
      'isComplete': isComplete,
      'progress': progress,
      'remainingProgress': remainingProgress,
      'formattedTime': formattedTime,
    };
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('CountdownTimer: Disposing timer');
    }
    _timer?.cancel();
    super.dispose();
  }
} 