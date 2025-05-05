import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../providers/major/teacher_settings_provider.dart';
import 'package:provider/provider.dart';

class UserInfoHeader extends StatelessWidget {
  const UserInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teacherProvider =
        Provider.of<TeacherSettingsProvider>(context, listen: true);

    final String title = teacherProvider.teacherName.isNotEmpty
        ? teacherProvider.teacherName
        : Config().appName;

    final bool hasEmail = teacherProvider.email.isNotEmpty;

    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar and edit button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
            children: [
              // Avatar with elevation
              SizedBox(
                height: 56,
                width: 56,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: teacherProvider.logo != null
                      ? Image.memory(
                          teacherProvider.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/icon/app_icon.png',
                              fit: BoxFit.contain,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome',
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        fontSize: 16, // Slightly reduced font size for better fit
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Edit button with better styling
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/teacher/edit_settings',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.edit,
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          if (hasEmail) ...[
            const SizedBox(height: 8),
            // Email with icon for better visual hierarchy
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    teacherProvider.email,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}