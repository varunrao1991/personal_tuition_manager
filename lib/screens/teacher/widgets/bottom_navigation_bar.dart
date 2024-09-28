import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Students',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
