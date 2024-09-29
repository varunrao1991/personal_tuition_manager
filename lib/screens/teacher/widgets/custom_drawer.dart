import 'package:flutter/material.dart';
import 'package:padmayoga/screens/teacher/holiday_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/confirmation_modal.dart';
import '../../../widgets/show_custom_center_modal.dart';
import 'edit_profile_screen.dart';
import '../../about_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _logout(context) {
    showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Do you want to logout from page?',
        confirmButtonText: 'Logout',
      ),
    ).then((success) async {
      if (success != null && success) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  const CircleAvatar(radius: 40),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('My Holidays'),
            onTap: () {
              Navigator.pushNamed(context, '/holidays');
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
