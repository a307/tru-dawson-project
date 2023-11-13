import 'package:crypt/crypt.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

Future<Map<String, SharedPreferences>> getSharedPreferences() async {
  final SharedPreferences emailPref = await SharedPreferences.getInstance();
  final SharedPreferences passwordPref = await SharedPreferences.getInstance();
  return {"email": emailPref, "password": passwordPref};
}


class _SignInState extends State<SignIn> {
  dynamic variable = getJSON();

  @override
  Widget build(BuildContext context) {
    // Initialize form key, used for validation later on
    final _formKey = GlobalKey<FormBuilderState>();
    // Keep track of the options from the dropdown
    int? option;
    // Initialize an instance of AuthService, used to create a user with a unique user id
    final AuthService auth = AuthService();
    // Allows text boxes data to be read later on
    final TextEditingController emailTEC = TextEditingController();
    final TextEditingController passwordTEC = TextEditingController();

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/DG-Home-3-Large.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double boxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth * 0.9;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 50.0, // Adjust the top position as needed
                    child: GestureDetector(
                      onTap: () {
                        // Handle tap to dismiss the keyboard
                        FocusScope.of(context).unfocus();
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          width: boxWidth,
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'lib/assets/dawson_updated_logo.png',
                                width: 500,
                              ),
                              SizedBox(height: 20.0),
                              FormBuilder(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                      name: "email",
                                      controller: emailTEC,
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    FormBuilderTextField(
                                      name: "password",
                                      obscureText: true,
                                      controller: passwordTEC,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Placeholder for login logic
                                            dynamic result = await auth.SignInEmailPass(
                                              emailTEC.text.trim(),
                                              passwordTEC.text.trim(),
                                            );

                                            if (result == null) {
                                              print('error signing in');
                                              showAlertDialog(
                                                context,
                                                "User Not Found!",
                                                "Email or password may be incorrect. \nDid you Sign Up?",
                                                false,
                                              );
                                            } else {
                                              print('user has signed in');
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return Material(
                                                      child: Generator(
                                                        list,
                                                        separatedForms,
                                                        result,
                                                        auth,
                                                        emailTEC.text,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                              print(result.uid);
                                            }
                                            print("");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFFC00205),
                                            minimumSize: Size(300, 45),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text("Login"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Placeholder for sign-up logic
                                            dynamic result = await auth.SignUp(
                                              emailTEC.text.trim(),
                                              passwordTEC.text.trim(),
                                            );

                                            if (result == null) {
                                              print('error signing up');
                                              showAlertDialog(
                                                context,
                                                "Error Signing Up",
                                                "Please try again.",
                                                false,
                                              );
                                            } else {
                                              print('user has signed up');
                                              showAlertDialog(
                                                context,
                                                'Successful Sign Up!',
                                                "Please press Sign In.",
                                                true,
                                              );
                                              print(result.uid);
                                            }
                                            print("");
                                            debugPrint(
                                              _formKey.currentState?.instantValue.toString() ?? '',
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFFC00205),
                                            minimumSize: Size(300, 45),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text("Sign up"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Placeholder for offline sign-in logic
                                            Map<String, SharedPreferences> sharedPreferences =
                                                await getSharedPreferences();
                                            dynamic result = await auth.SignInEmailPassOffline(
                                              emailTEC.text,
                                              passwordTEC.text,
                                              sharedPreferences["email"]!.getString("email")!,
                                              sharedPreferences["password"]!
                                                  .getString("password")!,
                                            );

                                            if (result == false) {
                                              print('error signing in offline');
                                              showAlertDialog(
                                                context,
                                                "User Not Found!",
                                                "Email or password may be incorrect. \nDid you Sign Up?",
                                                false,
                                              );
                                            } else {
                                              print('user has signed in offline');
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(builder: (context) {
                                                return Material(
                                                  child: Generator(
                                                    list, separatedForms, result, auth, emailTEC.text),
                                                );
                                              }));
                                            }
                                            print("");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFFC00205),
                                            minimumSize: Size(300, 45),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text("Offline Sign In"),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}







// alert dialogs handling
showAlertDialog(
    BuildContext context, String title, String content, bool isGood) {
  // Set up the icon based on isGood
  Icon icon = isGood
      ? Icon(Icons.check, color: Colors.green, size: 48) // Green checkmark
      : Icon(Icons.close, color: Colors.red, size: 48); // Red X symbol

  // Set up the buttons
  Widget continueButton = TextButton(
    child: const Text("Continue"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Container(
      // Wrap the content in a Container
      constraints:
          BoxConstraints(maxHeight: 200), // Adjust the maxHeight as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon, // Display the icon
          SizedBox(height: 16), // Add spacing
          Text(title),
          Text(content),
        ],
      ),
    ),
    actions: [continueButton],
  );

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

List<Map<String, dynamic>>? separatedForms = [];
List<String> list = [];

// Map for holding section counts for each individual form. Each form name represents a key that leads to map containing the labels of each section and their respective counts if they are "Repeatable"
// Map<String, Map<String, int>> formSectionCounts = {};

getJSON() async {
  //Connect to Firebase Real time database
  final ref = FirebaseDatabase.instance.ref();
  //get instance of json
  final snapshot = await ref.get();

  //Convert DataSnapshot to JSON map (string of JSON form content)
  Map<String, dynamic>? jsonMap = dataSnapshotToMap(snapshot);
  Map<String, dynamic> convertedMap = {};
// Initialize an empty map with the desired type

  jsonMap?.forEach((key, value) {
    if (value is Map<Object?, Object?>) {
      // If the value is another map, recursively convert it
      Map<String, dynamic> convertedValue = convertToMap(value);
      convertedMap[key.toString()] = convertedValue;
    } else {
      // Otherwise, add the value as is
      convertedMap[key.toString()] = value as dynamic;
    }
  });

  // Since the Data snapshot grabs a giant block of data, it needs to be separated into separate forms
  convertedMap.forEach((key, value) {
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

Map<String, dynamic> convertToMap(Map<Object?, Object?> original) {
  Map<String, dynamic> converted = {};
  original.forEach((key, value) {
    if (value is Map<Object?, Object?>) {
      Map<String, dynamic> convertedValue = convertToMap(value);
      converted[key.toString()] = convertedValue;
    } else {
      converted[key.toString()] = value as dynamic;
    }
  });
  return converted;
}
