import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chess_timer.dart';

/// A widget to display a chess timer
class ChessTimerWidget extends StatelessWidget {
  /// The timer model
  final ChessTimer timer;
  
  /// Whether this timer is active (current player's turn)
  final bool isActive;
  
  /// Whether to show the timer in a compact format
  final bool isCompact;
  
  /// The color of the timer (usually matches the player's color)
  final Color color;
  
  /// Constructor
  const ChessTimerWidget({
    super.key,
    required this.timer,
    this.isActive = false,
    this.isCompact = false,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: timer,
      child: Consumer<ChessTimer>(
        builder: (context, timer, child) {
          return _buildTimerWidget(context, timer);
        },
      ),
    );
  }
  
  Widget _buildTimerWidget(BuildContext context, ChessTimer timer) {
    // Determine the color based on time remaining and active state
    final timeColor = _getTimeColor(timer);
    
    // Build the timer display
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 16.0,
        vertical: isCompact ? 4.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(isCompact ? 4.0 : 8.0),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade300,
          width: isActive ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon
          Icon(
            Icons.timer,
            color: timeColor,
            size: isCompact ? 16.0 : 24.0,
          ),
          SizedBox(width: isCompact ? 4.0 : 8.0),
          
          // Time display
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isCompact ? 16.0 : 24.0,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: timeColor,
              fontFamily: 'Roboto Mono, monospace',
            ),
            child: Text(timer.formattedTime),
          ),
          
          // Show state indicator for non-compact mode
          if (!isCompact) ...[
            SizedBox(width: isCompact ? 4.0 : 8.0),
            _buildStateIndicator(timer),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStateIndicator(ChessTimer timer) {
    // Show different indicators based on timer state
    switch (timer.state) {
      case TimerState.running:
        return const _PulsingDot(color: Colors.green);
      case TimerState.paused:
        return const Icon(Icons.pause, color: Colors.orange, size: 16.0);
      case TimerState.expired:
        return const Icon(Icons.flag, color: Colors.red, size: 16.0);
      case TimerState.stopped:
        return const Icon(Icons.stop, color: Colors.grey, size: 16.0);
      case TimerState.ready:
        return const Icon(Icons.play_arrow, color: Colors.blue, size: 16.0);
    }
  }
  
  Color _getTimeColor(ChessTimer timer) {
    // Return red for expired timer
    if (timer.state == TimerState.expired) {
      return Colors.red;
    }
    
    // Color based on time remaining
    if (timer.timeRemaining <= 10) {
      return Colors.red;
    } else if (timer.timeRemaining <= 30) {
      return Colors.orange;
    } else if (timer.timeRemaining <= 60) {
      return Colors.amber.shade700;
    } else {
      return isActive ? color : Colors.grey.shade700;
    }
  }
}

/// A pulsing dot animation for the running timer
class _PulsingDot extends StatefulWidget {
  final Color color;
  
  const _PulsingDot({required this.color});
  
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_animation.value),
          ),
        );
      },
    );
  }
}
