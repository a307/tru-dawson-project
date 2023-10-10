import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/database.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
              controller: passwordTEC,
            ),
            SizedBox(height: 20.0),
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
                      print(result.uid);
                    }
                    print("");
                    //print out data in form
                    debugPrint(
                        _formKey.currentState?.instantValue.toString() ?? '');

                    //Login to firebase
                  }
                },
                child: Text("Sign In")),
            SizedBox(height: 20),
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
                    } else {
                      print('user has signed up');
                      print(result.uid);
                    }
                    print("");
                    //print out data in form
                    debugPrint(
                        _formKey.currentState?.instantValue.toString() ?? '');

                    //Login to firebase
                  }
                },
                child: Text("Sign up"))
          ],
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context, String title, String content) {
  // set up the buttons
  Widget continueButton = TextButton(
    child: Text("Continue"),
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
