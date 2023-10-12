import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/code_page.dart';
import 'package:tru_dawson_project/database.dart';
import 'package:tru_dawson_project/generation.dart';
import 'package:tru_dawson_project/main.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  dynamic variable = getJSON();

  @override
  Widget build(BuildContext context) {
    //Initialize form key, used for validation later on
    final _formKey = GlobalKey<FormBuilderState>();
    //keep track of the options from the dropdown
    int? option;
    //Initilize instance of AuthService, used to create user with unique user id
    final AuthService auth = AuthService();
    //Allows text boxes data to be read later on
    final TextEditingController emailTEC = TextEditingController();
    final TextEditingController passwordTEC = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Text("Email"),
            FormBuilderTextField(
              name: "email",
              controller: emailTEC,
            ),
            SizedBox(height: 20.0),
            Text("Password"),
            FormBuilderTextField(
              name: "password",
              obscureText: true,
              controller: passwordTEC,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      //Validate that forms are valid with the formkey
                      if (_formKey.currentState!.saveAndValidate() == true) {
                        //attempt to sign in anonymously and get back result containing Uid
                        dynamic result = await auth.SignInEmailPass(
                            emailTEC.text.trim(), passwordTEC.text.trim());
                        //If theres data print out the Uid
                        if (result == null) {
                          print('error signing in');
                          showAlertDialog(context, "User Not Found!",
                              "Email or password incorrect. Please try again.");
                        } else {
                          print('user has signed in');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return CodePage(
                                  title: 'Dawson Group Forms',
                                  child:
                                      Generator(list, separatedForms, result),
                                );
                              },
                            ),
                          );
                          print(result.uid);
                        }
                        print("");
                      }
                    },
                    child: const Text("Sign In")),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () async {
                      //Validate that forms are valid with the formkey
                      if (_formKey.currentState!.saveAndValidate() == true) {
                        //attempt to sign in anonymously and get back result containing Uid
                        dynamic result = await auth.SignUp(
                            emailTEC.text.trim(), passwordTEC.text.trim());

                        //If theres data print out the Uid
                        if (result == null) {
                          print('error signing up');
                          showAlertDialog(
                              context, "Error Signing Up", "Please try again.");
                        } else {
                          print('user has signed up');
                          showAlertDialog(context, 'Successful Sign Up!',
                              "Please press Sign In.");
                          print(result.uid);
                        }
                        print("");
                        //print out data in form
                        debugPrint(
                            _formKey.currentState?.instantValue.toString() ??
                                '');

                        //Login to firebase
                      }
                    },
                    child: const Text("Sign up"))
              ],
            )
          ],
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context, String title, String content) {
  // set up the buttons
  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

List<Map<String, dynamic>>? separatedForms = [];
List<String> list = [];
getJSON() async {
  //Connect to Firebase Real time database
  final ref = FirebaseDatabase.instance.ref();
  //get instance of json
  final snapshot = await ref.get();

  //Convert DataSnapshot to JSON map (string of JSON form content)
  Map<String, dynamic>? jsonMap = dataSnapshotToMap(snapshot);

  // Since the Data snapshot grabs a giant block of data, it needs to be separated into separate forms
  jsonMap?.forEach((key, value) {
    // For each form in the original map, create a new map and add it to the list
    separatedForms?.add(value);
  });

  //Print data out if there is any
  if (snapshot.exists) {
    //print whole file structure
    //print(snapshot.value);

    //print just form 0
    //print(snapshot.child('form0').value);

    //Loop through forms
    for (int i = 0; i < snapshot.children.length; i++) {
      //print out form names from metadata, two ways, through snapshot or through map
      list.add(snapshot.child('form$i/metadata/formName').value.toString());
      //list.add(jsonMap?['form$i']['metadata']['formName']);

      //print(snapshot.child('form$i/metadata/formName').value);
      //print(jsonMap?['form$i']['metadata']['formName']);
    }
  } else {
    print('No data available.');
  }
}
