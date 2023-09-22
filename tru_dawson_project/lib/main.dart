import 'package:flutter/material.dart';

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];
void main() {
  runApp(const MaterialApp(home: CustomForm() //class
      ));
}

class CustomForm extends StatefulWidget {
  const CustomForm({super.key});

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
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
            const Text(
              'Enter Phone Number',
              textAlign: TextAlign.left,
            ),
            Material(
              child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: 'Enter a phone number',
                  labelText: 'Phone',
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text('Select from the Drop down'),
            DropdownButton(
                value: dropDownValue,
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    dropDownValue = value!;
                  });
                }),
            const SizedBox(height: 50),
            ElevatedButton(onPressed: () {}, child: const Text('Submit'))
          ],
        ),
      ),
    );
  }
}
