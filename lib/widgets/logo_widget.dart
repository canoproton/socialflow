import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogoWidget extends StatelessWidget {
  final bool showTitle;
  final String? version;
  final double size;

  const LogoWidget({
    super.key,
    this.showTitle = true,
    this.version,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 48,
          ),
        ),
        
        if (showTitle) ...[
          const SizedBox(height: 16),
          
          Text(
            'SocialFlow',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: -0.5,
            ),
          ),
          
          if (version != null) ...[
            const SizedBox(height: 4),
            Text(
              version!,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
