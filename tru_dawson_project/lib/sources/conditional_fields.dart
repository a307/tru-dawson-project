import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/database.dart';

class ConditionalFields extends StatefulWidget {
  const ConditionalFields({Key? key}) : super(key: key);

  @override
  State<ConditionalFields> createState() => _ConditionalFieldsState();
}

class _ConditionalFieldsState extends State<ConditionalFields> {
  //Initialize form key, used for validation later on
  final _formKey = GlobalKey<FormBuilderState>();
  //keep track of the options from the dropdown
  int? option;
  //Initilize instance of AuthService, used to create user with unique user id
  final AuthService auth = AuthService();
  //Allows text boxes data to be read later on
  final TextEditingController textfieldTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          FormBuilderDropdown<int>(
            name: 'options',
            validator: FormBuilderValidators.required(),
            decoration: const InputDecoration(
              label: Text('Select the option'),
            ),
            onChanged: (value) {
              setState(() {
                option = value;
              });
            },
            items: const [
              DropdownMenuItem(value: 0, child: Text('Show text field')),
              DropdownMenuItem(value: 1, child: Text('Show info text')),
            ],
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: option == 0,
            // Can use to recreate completely the field
            // maintainState: false,
            child: FormBuilderTextField(
              name: 'textfield',
              controller: textfieldTEC,
              validator: FormBuilderValidators.minLength(4),
              decoration: const InputDecoration(
                label: Text('Magic field'),
              ),
            ),
          ),
          Visibility(
            visible: option == 1,
            child: const Text('Magic info'),
          ),
          const SizedBox(height: 10),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              //Validate that forms are valid with the formkey
              if (_formKey.currentState!.saveAndValidate() == true) {
                //attempt to sign in anonymously and get back result containing Uid
                dynamic result = await auth.signInAnon();
                //If theres data print out the Uid
                if (result == null) {
                  print('error signing in');
                } else {
                  print('user has signed in');
                  print(result.uid);
                }
                //print out data in form
                debugPrint(
                    _formKey.currentState?.instantValue.toString() ?? '');
                //converting int options to strings
                String optionStr = '';
                if (option == 0) {
                  optionStr = 'Show text field';
                } else if (option == 1) {
                  optionStr = 'Show info text';
                }
                //send data to the database
                await DatabaseService(uid: result.uid)
                    .updateConditionalFormData(optionStr, textfieldTEC.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
