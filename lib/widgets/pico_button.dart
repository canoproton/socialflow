import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PicoButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isSecondary;
  final bool isOutline;
  final bool isLarge;
  final bool isSmall;
  final bool isLoading;

  const PicoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isOutline = false,
    this.isLarge = false,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    if (isOutline) {
      backgroundColor = Colors.transparent;
      foregroundColor = AppTheme.primaryColor;
      borderColor = AppTheme.primaryColor;
    } else if (isSecondary) {
      backgroundColor = AppTheme.secondaryColor;
      foregroundColor = Colors.white;
      borderColor = AppTheme.secondaryColor;
    } else {
      backgroundColor = AppTheme.primaryColor;
      foregroundColor = Colors.white;
      borderColor = AppTheme.primaryColor;
    }

    return SizedBox(
      width: isLarge ? double.infinity : null,
      height: isSmall ? 36 : 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isOutline ? BorderSide(color: borderColor, width: 1.5) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 0,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: isLarge ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}