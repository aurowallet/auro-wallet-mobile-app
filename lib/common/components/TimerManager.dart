import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auro_wallet/common/components/loadingCircle.dart';

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

  Future<void> _handleRefresh() async {
    print('Starting refresh');
    try {
      await onCountdownEnd(); // Wait for async callback to complete
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
    return ValueListenableBuilder<TimerState>(
      valueListenable: widget.timerManager,
      builder: (context, state, child) {
        if (state.intervalTime <= 0) {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
        // return SizedBox(
        //   width: 30,
        //   child: Container(
        //     height: 24,
        //     alignment: Alignment.centerRight,
        //     child: state.isRefreshing
        //         ? _buildRefreshIcon()
        //         : Text(
        //             ' (${state.countdown})',
        //             style: const TextStyle(
        //               fontSize: 12,
        //               color: Color(0x80000000),
        //               fontWeight: FontWeight.w600,
        //             ),
        //             textAlign: TextAlign.right,
        //           ),
        //   ),
        // );
      },
    );
  }

  Widget _buildRefreshIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Center(
        child: RotatingCircle(
          size: 14,
        ),
      ),
    );
  }
}
