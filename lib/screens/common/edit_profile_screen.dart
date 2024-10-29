import 'package:flutter/material.dart';
import 'package:padmayoga/screens/common/profile_picture_editor.dart';
import '../../widgets/navigation_bar.dart';
import 'change_personal_info.dart';
import 'password_change_form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ProfilePictureEditor(),
      const PersonalInfoForm(),
      const PasswordChangeForm(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        navItems: const [
          NavItem(icon: Icons.person, label: 'Picture'),
          NavItem(icon: Icons.person, label: 'Info'),
          NavItem(icon: Icons.lock, label: 'Password'),
        ],
      ),
    );
  }
}
