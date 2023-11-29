import 'package:crypt/crypt.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/generation.dart';
import 'dart:io';
import 'dart:convert';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

//Creates two instances of SharedPreferences, one for email, one for password. Used when signing in offline. User first signs in online and then they are allowed to sign in offline as the last person who signed in.
Future<Map<String, SharedPreferences>> getSharedPreferences() async {
  //Get shared preference instance
  final SharedPreferences emailPref = await SharedPreferences.getInstance();
  final SharedPreferences passwordPref = await SharedPreferences.getInstance();
  //return map of sharedpreferences
  return {"email": emailPref, "password": passwordPref};
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    //Initialize form key, used for validation later on
    final formKey = GlobalKey<FormBuilderState>();
    //keep track of the options from the dropdown
    int? option;
    //Initilize instance of AuthService, used to create user with unique user id
    final AuthService auth = AuthService();
    //Allows text boxes data to be read later on
    final TextEditingController emailTEC = TextEditingController();
    final TextEditingController passwordTEC = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap the content with SingleChildScrollView for scrolling when typing
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Image.asset(
                'lib/assets/dawson_updated_logo.png', //  dawson group logo image
                //width: 500,
                width: MediaQuery.of(context).size.width * 0.8, // adjust for iphone
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 300,
                child: FormBuilderTextField(
                  name: "email",
                  //assign controller so the contents can be read later on
                  controller: emailTEC,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              //Text("Password"),
              SizedBox(
                width: 300,
                child: FormBuilderTextField(
                  name: "password",
                  obscureText: true,
                  //assign controller so the contents can be read later on
                  controller: passwordTEC,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        //Validate that forms are valid with the formkey
                        if (formKey.currentState!.saveAndValidate() == true) {
                          //attempt to sign in using email and password and get back result containing Uid
                          dynamic result = await auth.SignInEmailPass(
                              emailTEC.text.trim(), passwordTEC.text.trim());
                          //get shared preferences isntances for email and password
                          Map<String, SharedPreferences> sharedPreferences =
                              await getSharedPreferences();
                          //assign shared preferences data
                          await sharedPreferences["email"]
                              ?.setString('email', emailTEC.text);
                          await sharedPreferences['password']?.setString(
                              'password',
                              //hash password
                              Crypt.sha256(passwordTEC.text).toString());
                          //if no result (bad sign in) display error messsage
                          if (result == null) {
                            print('error signing in');
                            showAlertDialog(
                                context,
                                "User Not Found!",
                                "Email or password may be incorrect. \nDid you Sign Up?",
                                false);
                          } else {
                            print('user has signed in');
                            //if user signed in successfully, get JSON data from Firebase Realtime Database
                            dynamic variable = await getJSON();
                            //push main menu page to front
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return Material(
                                      //supply generator with the list of forms, the data for each form, login result, auth result, and email
                                      child: Generator(list, separatedForms,
                                          result, auth, emailTEC.text));
                                },
                              ),
                            );
                            print(result.uid);
                          }
                          print("");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC00205),
                        minimumSize: const Size(300, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust the radius for roundness
                        ),
                      ),
                      child: const Text("Login")),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        //Validate that forms are valid with the formkey
                        if (formKey.currentState!.saveAndValidate() == true) {
                          //attempt to sign up with email and password and get back result containing Uid
                          dynamic result = await auth.SignUp(
                              emailTEC.text.trim(), passwordTEC.text.trim());
                          if (result == null) {
                            print('error signing up');
                            showAlertDialog(context, "Error Signing Up",
                                "Please try again.", false);
                          } else {
                            print('user has signed up');
                            //user has signed in successfully, prompt user to sign in with those credentials now
                            showAlertDialog(context, 'Successful Sign Up!',
                                "Please press Sign In.", true);
                            print(result.uid);
                          }
                          print("");
                          //print out data in form
                          debugPrint(
                              formKey.currentState?.instantValue.toString() ??
                                  '');

                          //Login to firebase
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC00205),
                        minimumSize: const Size(300, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust the radius for roundness
                        ),
                      ),
                      child: const Text("Sign up"))
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        //Validate that forms are valid with the formkey
                        if (formKey.currentState!.saveAndValidate() == true) {
                          //get email and password shared preferences
                          Map<String, SharedPreferences> sharedPreferences =
                              await getSharedPreferences();
                          //get form data shared preferences
                          Map<String, SharedPreferences> sharedPreferencesSnap =
                              await getSharedPreferencesSnap();
                          //sign in with credentials in inputs, and verify they match with shared preferences (last user log in)
                          dynamic result = await auth.SignInEmailPassOffline(
                              emailTEC.text,
                              passwordTEC.text,
                              sharedPreferences["email"]!.getString("email")!,
                              sharedPreferences["password"]!
                                  .getString("password")!);
                          //users dont match
                          if (result == false) {
                            print('error signing in offline');
                            showAlertDialog(
                                context,
                                "User Not Found!",
                                "Email or password may be incorrect. \nDid you Sign Up?",
                                false);
                          }
                          //users match
                          else {
                            print('user has signed in offline');
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Material(
                                  //push generator to forfront and give it sharedpreferences formdata and list of forms, result from earlier, auth, and email from form
                                  child: Generator(
                                      sharedPreferencesSnap["list"]!
                                          .getStringList("list")!,
                                      jsonDecode(sharedPreferencesSnap[
                                                  "separatedForms"]!
                                              .getString("separatedForms")!)
                                          .cast<Map<String, dynamic>>()
                                          .toList(),
                                      result,
                                      auth,
                                      emailTEC.text));
                            }));
                          }
                          print("");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC00205),
                        minimumSize: const Size(300, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust the radius for roundness
                        ),
                      ),
                      child: const Text("Offline Sign In"))
                ],
              )
            ],
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
      ? const Icon(Icons.check,
          color: Colors.green, size: 48) // Green checkmark
      : const Icon(Icons.close, color: Colors.red, size: 48); // Red X symbol

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
      constraints: const BoxConstraints(
          maxHeight: 200), // Adjust the maxHeight as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon, // Display the icon
          const SizedBox(height: 16), // Add spacing
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

Future<Map<String, SharedPreferences>> getSharedPreferencesSnap() async {
  final SharedPreferences separatedPref = await SharedPreferences.getInstance();
  final SharedPreferences listPref = await SharedPreferences.getInstance();
  return {"separatedForms": separatedPref, "list": listPref};
}

Future<bool?> getJSON() async {
  Map<String, SharedPreferences> sharedPreferences =
      await getSharedPreferencesSnap();
  try {
    //check if not web so we can use InternetAddress.lookup()
    if (!kIsWeb) {
      //If not on web (IOS) use this to check if the internet is available
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        //Connect to Firebase Real time database
        final ref = FirebaseDatabase.instance.ref().child("Dawson_Forms");
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
          //Loop through forms
          for (int i = 0; i < snapshot.children.length; i++) {
            //print out form names from metadata, two ways, through snapshot or through map
            list.add(
                snapshot.child('form$i/metadata/formName').value.toString());
          }

          sharedPreferences["separatedForms"]!
              .setString("separatedForms", json.encode(separatedForms));
          // print(separatedForms.toString());
          sharedPreferences["list"]!.setStringList("list", list);
          return true;
        } else {
          print('No data available.');
          return false;
        }
      }
    }
    //If web then dont check for internet connection
    else {
      //Connect to Firebase Real time database
      final ref = FirebaseDatabase.instance.ref().child("Dawson_Forms");
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
        //Loop through forms
        for (int i = 0; i < snapshot.children.length; i++) {
          //print out form names from metadata, two ways, through snapshot or through map
          list.add(snapshot.child('form$i/metadata/formName').value.toString());
        }

        //add form data to sharedpreferences in a json format
        sharedPreferences["separatedForms"]!
            .setString("separatedForms", json.encode(separatedForms));
        // print(separatedForms.toString());
        //add list of forms to sharedpreferences
        sharedPreferences["list"]!.setStringList("list", list);
        return true;
      } else {
        print('No data available.');
        return false;
      }
    }
  } on SocketException catch (_) {
    print('not connected');
    //print(sharedPreferences["separatedForms"]!.getString("separatedForms")!);
    //if not connected get sharedpreferences and decode the data back into separated forms
    separatedForms = jsonDecode(
            sharedPreferences["separatedForms"]!.getString("separatedForms")!)
        .cast<Map<String, dynamic>>()
        .toList();
    print(separatedForms);
    //get list from sharedpreferences
    list = sharedPreferences["list"]!.getStringList("list")!;
    return false;
  }
  return false;
}

//Convert Map<Object?, Object?> to Map<String, dynamic>
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
