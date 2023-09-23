import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
void main() {
  runApp(MaterialApp(home: CustomForm() //class
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
            SizedBox(
              height: 20,
            ),
            Material(
              child: TextFormField(
                controller: usernameTEC,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter username',
                  labelText: 'Username',
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Material(
              child: TextFormField(
                controller: passwordTEC,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.password),
                  hintText: 'Enter a password',
                  labelText: 'Password',
                ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
                onPressed: () {
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
