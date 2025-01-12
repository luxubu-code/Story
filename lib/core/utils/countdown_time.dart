import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTime extends StatefulWidget {
  final DateTime time;
  final TextStyle? textStyle;
  final VoidCallback? function;

  const CountdownTime(
      {super.key, required this.time, this.textStyle, this.function});

  @override
  State<CountdownTime> createState() => _CountdownTimeState();
}

class _CountdownTimeState extends State<CountdownTime> {
  Timer? _timer; // Đối tượng Timer để đếm từng giây
  late Duration _timeRemaining; // Khoảng thời gian còn lại
  late DateTime _adjustedTargetTime;

  @override
  void initState() {
    super.initState();
    _adjustedTargetTime = widget.time.add(Duration(minutes: 1));
    _calculateTimeRemaining(); // Tính thời gian còn lại
    _startTimer(); // Bắt đầu đếm ngược
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Thêm setState để cập nhật UI
        _calculateTimeRemaining();
        if (_timeRemaining.inSeconds <= 0) {
          widget.function?.call();
          _timer?.cancel();
        }
      });
    });
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    _timeRemaining = _adjustedTargetTime
        .difference(now); // Tính khoảng cách đến thời điểm đích
    if (_timeRemaining.isNegative) {
      _timeRemaining = Duration.zero; // Đảm bảo không hiện thị thời gian âm
    }
  }

  String _formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '$days ngày ${hours}h ${minutes}p';
    } else if (hours > 0) {
      return '${hours}h ${minutes}p ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}p ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_timeRemaining),
      style: widget.textStyle,
    );
  }
}
