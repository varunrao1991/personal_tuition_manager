import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final PreferredSizeWidget? navigationBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.navigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: actions,
        bottom: bottom,
      ),
      drawer: const CustomDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navigationBar,
    );
  }
}