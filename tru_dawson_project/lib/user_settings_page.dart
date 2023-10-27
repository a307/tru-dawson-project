// TODO Implement this library.

import 'package:flutter/material.dart';

class UserSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205), // Set the background color to #234094
        title: Text('User Settings'),
      ),
      body: Center(
        child: Text('This is the User Settings Page'),
      ),
    );
  }
}
