import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome to Student Home!',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const Text('View Schedule'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
