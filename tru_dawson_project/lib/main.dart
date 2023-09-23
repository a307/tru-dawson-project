import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tru_dawson_project/database.dart';
import 'firebase_options.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: CustomForm() //class
      ));
}

class CustomForm extends StatefulWidget {
  const CustomForm({super.key});

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final TextEditingController usernameTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String dropDownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Material(
              child: TextFormField(
                controller: usernameTEC,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Enter username',
                  labelText: 'Username',
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Material(
              child: TextFormField(
                controller: passwordTEC,
                decoration: const InputDecoration(
                  icon: Icon(Icons.password),
                  hintText: 'Enter a password',
                  labelText: 'Password',
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
                onPressed: () async {
                  await DatabaseService(uid: 'EEev5kPswkPQQJczwg7X')
                      .updateUserData(usernameTEC.text, passwordTEC.text);
                  print(usernameTEC.text);
                  print(passwordTEC.text);
                },
                child: const Text('Submit'))
          ],
        ),
      ),
    );
  }
}
