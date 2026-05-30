import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecentAnalysisCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int score;
  final IconData icon;
  final String? trailingLabel; // e.g. "高風險"
  final VoidCallback? onTap;

  const RecentAnalysisCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.score,
    required this.icon,
    this.trailingLabel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowScore = score < 40;
    
    // Choose colors based on credibility score
    final statusColor = isLowScore ? AppTheme.tertiaryColor : AppTheme.primaryColor;
    final progressBgColor = AppTheme.surfaceContainer;
    final cardBgColor = isLowScore ? AppTheme.tertiaryContainerColor.withOpacity(0.05) : AppTheme.surfaceColor;
    final cardBorderColor = isLowScore ? AppTheme.tertiaryContainerColor.withOpacity(0.2) : AppTheme.outlineVariant;
    
    final leadingBgColor = isLowScore ? AppTheme.errorContainerColor : AppTheme.surfaceContainerHigh;
    final leadingIconColor = isLowScore ? AppTheme.errorColor : AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: leadingBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: leadingIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorContainerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: AppTheme.errorColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trailingLabel!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressBgColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: score / 100.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$score%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'VeriScore',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
