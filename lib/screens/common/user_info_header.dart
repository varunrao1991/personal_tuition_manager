import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/handle_errors.dart';
import 'edit_profile_screen.dart';

class UserInfoHeader extends StatefulWidget {
  const UserInfoHeader({super.key});

  @override
  _UserInfoHeaderState createState() => _UserInfoHeaderState();
}

class _UserInfoHeaderState extends State<UserInfoHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadThumbnail();
    });
  }

  Future<void> _checkAndLoadThumbnail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (authProvider.thumbnail == null) {
        await authProvider.loadMyThumbnail();
      }
    } catch (e) {
      handleErrors(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfileScreen(),
          ),
        );
      },
      child: DrawerHeader(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
        ),
        child: SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: authProvider.thumbnail != null
                    ? MemoryImage(authProvider.thumbnail!)
                    : null,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : authProvider.thumbnail == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Unknown User',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.mobile ?? 'N/A',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
