import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// TooltipOverlay - Reusable overlay component for contextual hints
///
/// Displays a semi-transparent overlay with a tooltip bubble pointing to a target widget.
/// Includes accessibility support following the ExcludeSemantics + Semantics pattern.
///
/// **Usage:**
/// ```dart
/// TooltipOverlay(
///   position: TooltipPosition.bottom,
///   message: 'Lihat prakiraan cuaca untuk merencanakan aktivitas lapangan',
///   onDismiss: () => setState(() => _showTooltip = false),
///   child: WeatherWidget(),
/// )
/// ```
enum TooltipPosition {
  top,
  bottom;
}

/// Tooltip configuration constants
class TooltipOverlayTheme {
  static const Color overlayColor = Colors.black54; // 50% opacity
  static const Color tooltipBackground = Colors.white;
  static const double tooltipBorderRadius = 8.0;
  static const double arrowSize = 12.0;
  static const EdgeInsets tooltipPadding = EdgeInsets.all(16);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double tooltipMaxWidth = 280.0;
}

class TooltipOverlay extends StatefulWidget {
  /// The target widget to display tooltip for
  final Widget child;

  /// The message to show in the tooltip
  final String message;

  /// Position of the tooltip relative to the child (top or bottom)
  final TooltipPosition position;

  /// Callback when user dismisses the tooltip
  final VoidCallback onDismiss;

  const TooltipOverlay({
    super.key,
    required this.child,
    required this.message,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: TooltipOverlayTheme.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Show overlay after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlayContent(
        layerLink: _layerLink,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        position: widget.position,
        message: widget.message,
        onDismiss: _handleDismiss,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}

/// Full-screen overlay with semi-transparent background and tooltip
class _TooltipOverlayContent extends StatelessWidget {
  final LayerLink layerLink;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final TooltipPosition position;
  final String message;
  final VoidCallback onDismiss;

  const _TooltipOverlayContent({
    required this.layerLink,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.position,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Stack(
        children: [
          // Semi-transparent overlay (AC1: 50% opacity black)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: TooltipOverlayTheme.overlayColor,
              ),
            ),
          ),
          // Tooltip bubble positioned relative to target
          Positioned.fill(
            child: ScaleTransition(
              scale: scaleAnimation,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: position == TooltipPosition.bottom
                    ? const Offset(0, TooltipOverlayTheme.arrowSize)
                    : Offset.zero,
                targetAnchor: position == TooltipPosition.bottom
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                followerAnchor: position == TooltipPosition.bottom
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: _TooltipBubble(
                  message: message,
                  position: position,
                  onDismiss: onDismiss,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tooltip content bubble with arrow and dismiss button
class _TooltipBubble extends StatelessWidget {
  final String message;
  final TooltipPosition position;
  final VoidCallback onDismiss;

  const _TooltipBubble({
    required this.message,
    required this.position,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: message,
        hint: 'Tap Mengerti untuk menutup',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Arrow at top if tooltip is below target
            if (position == TooltipPosition.bottom) _buildArrow(pointingUp: true),
            // Tooltip bubble
            Container(
              constraints: const BoxConstraints(
                maxWidth: TooltipOverlayTheme.tooltipMaxWidth,
              ),
              decoration: BoxDecoration(
                color: TooltipOverlayTheme.tooltipBackground,
                borderRadius: BorderRadius.circular(
                    TooltipOverlayTheme.tooltipBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: TooltipOverlayTheme.tooltipPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message text
                  Text(
                    message,
                    style: AppTextStyles.w500s12.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Dismiss button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size(72, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                      child: const Text('Mengerti'),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow at bottom if tooltip is above target
            if (position == TooltipPosition.top) _buildArrow(pointingUp: false),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow({required bool pointingUp}) {
    return CustomPaint(
      size: const Size(
          TooltipOverlayTheme.arrowSize * 2, TooltipOverlayTheme.arrowSize),
      painter: _ArrowPainter(
        color: TooltipOverlayTheme.tooltipBackground,
        pointingUp: pointingUp,
      ),
    );
  }
}

/// Custom painter for tooltip arrow
class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointingUp;

  _ArrowPainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingUp) {
      // Pointing up (arrow at top of tooltip, tooltip below target)
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      // Pointing down (arrow at bottom of tooltip, tooltip above target)
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointingUp != pointingUp;
  }
}
