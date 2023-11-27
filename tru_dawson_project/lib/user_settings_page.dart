// TODO Implement this library.

import 'package:flutter/material.dart';

class UserSettingsPage extends StatelessWidget {
  const UserSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC00205), // Set the background color to #234094
        title: const Text('User Settings'),
      ),
      body: const Center(
        child: Text('This is the User Settings Page'),
      ),
    );
  }
}
