import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tru_dawson_project/authenticate.dart';
import 'package:tru_dawson_project/database.dart';
import 'firebase_options.dart';
import 'package:tru_dawson_project/auth.dart';

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
  final AuthService auth = AuthService();
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
                  hintText: 'Enter in text',
                  labelText: 'Text',
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
                  hintText: 'Enter a text',
                  labelText: 'text',
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
                onPressed: () async {
                  dynamic result = await auth.signInAnon();
                  if (result == null) {
                    print('error signing in');
                  } else {
                    print('user has signed in');
                    print(result.uid);
                  }
                  await DatabaseService(uid: result.uid)
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
