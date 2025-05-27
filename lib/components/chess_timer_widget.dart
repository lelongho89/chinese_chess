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
    return RepaintBoundary(
      child: ChangeNotifierProvider.value(
        value: timer,
        child: Consumer<ChessTimer>(
          builder: (context, timer, child) {
            return _buildTimerWidget(context, timer);
          },
        ),
      ),
    );
  }

  Widget _buildTimerWidget(BuildContext context, ChessTimer timer) {
    // Determine the colors based on active state and time remaining
    final colors = _getTimerColors(timer);

    // Build the timer display
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 16.0,
        vertical: isCompact ? 4.0 : 8.0,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(isCompact ? 4.0 : 8.0),
        border: Border.all(
          color: colors.borderColor,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: colors.borderColor.withOpacity(0.3),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer icon
          Icon(
            Icons.timer,
            color: colors.iconColor,
            size: isCompact ? 16.0 : 24.0,
          ),
          SizedBox(width: isCompact ? 4.0 : 8.0),

          // Time display
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isCompact ? 16.0 : 24.0,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: colors.textColor,
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

  _TimerColors _getTimerColors(ChessTimer timer) {
    // Handle expired timer
    if (timer.state == TimerState.expired) {
      return _TimerColors(
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red,
        textColor: Colors.red.shade800,
        iconColor: Colors.red,
      );
    }

    // Handle low time warnings
    if (timer.timeRemaining <= 10) {
      return _TimerColors(
        backgroundColor: isActive ? Colors.red.shade50 : Colors.red.shade100,
        borderColor: Colors.red,
        textColor: Colors.red.shade800,
        iconColor: Colors.red,
      );
    } else if (timer.timeRemaining <= 30) {
      return _TimerColors(
        backgroundColor: isActive ? Colors.orange.shade50 : Colors.orange.shade100,
        borderColor: Colors.orange,
        textColor: Colors.orange.shade800,
        iconColor: Colors.orange,
      );
    }

    // Normal time colors based on active state
    if (isActive) {
      return _TimerColors(
        backgroundColor: color.withOpacity(0.15),
        borderColor: color,
        textColor: _getDarkerColor(color),
        iconColor: color,
      );
    } else {
      return _TimerColors(
        backgroundColor: Colors.grey.shade50,
        borderColor: Colors.grey.shade300,
        textColor: Colors.grey.shade600,
        iconColor: Colors.grey.shade500,
      );
    }
  }

  /// Get a darker version of the given color for text
  Color _getDarkerColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor();
  }
}

/// Color scheme for timer widget
class _TimerColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  const _TimerColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
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
      duration: const Duration(seconds: 2), // Slower animation for better performance
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
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
      ),
    );
  }
}
