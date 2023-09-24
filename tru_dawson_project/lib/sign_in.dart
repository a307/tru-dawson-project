import 'package:flutter/material.dart';
import 'package:tru_dawson_project/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 50, 87),
      appBar: AppBar(
        actions: [],
        backgroundColor: Colors.grey,
        title: const Text('Sign In to Dawson'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ElevatedButton(
          child: const Text('Sign in Anon'),
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if (result == null) {
              print('error signing in');
            } else {
              print('user has signed in');
              print(result);
            }
          },
        ),
      ),
    );
  }
}
