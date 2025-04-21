import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_card.dart';

class MonthInfoCard extends StatelessWidget {
  final DateTime month;
  final bool isSelected;
  final Widget child;
  final Future<void> Function() onTap;
  final bool showYear;

  const MonthInfoCard({
    super.key,
    required this.month,
    required this.isSelected,
    required this.child,
    required this.onTap,
    this.showYear = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double cardWidth = MediaQuery.of(context).size.width / 3.5;
    final monthName = DateFormat('MMM').format(month);
    final year = DateFormat('y').format(month);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await onTap();
        },
        child: CustomCard(
          isSelected: isSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  monthName.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected? colorScheme.primary 
                        : colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                // Year (conditionally shown)
                if (showYear)
                  Text(
                    year,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.8)
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Child content with proper theming
                DefaultTextStyle.merge(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}