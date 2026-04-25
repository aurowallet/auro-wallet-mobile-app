import 'dart:async';
import 'package:flutter/material.dart';

class TimerManager extends ValueNotifier<TimerState> {
  Timer? _timer;
  final Future<void> Function() onCountdownEnd;
  bool _isHandlingRefresh = false;

  TimerManager({
    required int intervalTime,
    required this.onCountdownEnd,
  }) : super(TimerState(
          countdown: intervalTime,
          isRefreshing: false,
          intervalTime: intervalTime,
        )) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (value.countdown > 1) {
        value = TimerState(
          countdown: value.countdown - 1,
          isRefreshing: false,
          intervalTime: value.intervalTime,
        );
      } else if (value.countdown == 1 && !_isHandlingRefresh) {
        _timer?.cancel(); // Stop the timer immediately
        _isHandlingRefresh = true; // Set guard before state update
        value = TimerState(
          countdown: 1, // Keep at 1 to avoid showing 0
          isRefreshing: true,
          intervalTime: value.intervalTime,
        );
        _handleRefresh();
      }
    });
  }

  static const int _refreshTimeoutSeconds = 30;

  Future<void> _handleRefresh() async {
    print('Starting refresh');
    try {
      await onCountdownEnd().timeout(
        const Duration(seconds: _refreshTimeoutSeconds),
        onTimeout: () {
          print('Refresh timed out after $_refreshTimeoutSeconds seconds');
        },
      );
    } catch (e) {
      print('Refresh failed: $e');
    }
    print('Refresh completed, resetting state');
    value = TimerState(
      countdown: value.intervalTime,
      isRefreshing: false,
      intervalTime: value.intervalTime,
    );
    _isHandlingRefresh = false;
    _startTimer(); // Restart the timer after refresh
  }

  void setIntervalTime(int newInterval) {
    print('Setting new interval: $newInterval');
    _timer?.cancel();
    _isHandlingRefresh = false;
    value = TimerState(
      countdown: newInterval,
      isRefreshing: false,
      intervalTime: newInterval,
    );
    _startTimer();
  }

  int getIntervalTime() {
    return value.intervalTime;
  }

  @override
  void dispose() {
    print('TimerManager disposed');
    _timer?.cancel();
    super.dispose();
  }
}

class TimerState {
  final int countdown;
  final bool isRefreshing;
  final int intervalTime;

  TimerState({
    required this.countdown,
    required this.isRefreshing,
    required this.intervalTime,
  });
}

// CountdownTimer component
class CountdownTimer extends StatefulWidget {
  final TimerManager timerManager;

  const CountdownTimer({
    Key? key,
    required this.timerManager,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.timerManager,
      builder: (context, child) {
        if (widget.timerManager.value.intervalTime <= 0) {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
