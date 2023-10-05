//RUN THESE:
//flutter pub add form_builder_validators
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'sources/conditional_fields.dart';
import 'sources/dynamic_fields.dart';
import 'sources/related_fields.dart';
import 'code_page.dart';
import 'sources/complete_form.dart';
import 'sources/custom_fields.dart';
import 'sources/signup_form.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tru_dawson_project/database.dart';
import 'firebase_options.dart';
import 'package:tru_dawson_project/auth.dart';

// List to hold all of the individual JSONs
List<Map<String, dynamic>>? separatedForms = [];

void main() async {
  List<String> list = [];

  //Ensures flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize Firebase
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyChE23oQe0lYW_Y2TAKbCCjl1ox5yTikTc',
    appId: "1:203503274066:web:d1b68e01a632af4186378b",
    messagingSenderId: '203503274066',
    projectId: "tru-dawson-project-2023",
    //Must be used to connect to Firebase Realtime database
    databaseURL: 'https://tru-dawson-project-2023-default-rtdb.firebaseio.com/',
  ));
  //Connect to Firebase Real time database
  final ref = FirebaseDatabase.instance.ref();
  //get instance of json: simple_road_inspection
  final snapshot = await ref.get();

  //Convert DataSnapshot to JSON map (string of JSON form content)
  Map<String, dynamic>? jsonMap = dataSnapshotToMap(snapshot);

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
  //Run Application starting with MyApp as home
  runApp(MaterialApp(home: MyApp(list) //class
      ));
}

//Convert DataSnapshot to JSON map
Map<String, dynamic>? dataSnapshotToMap(DataSnapshot? snapshot) {
  if (snapshot == null || snapshot.value == null) {
    return null;
  }

  Map<String, dynamic> result = {};

  // Check if the value is a Map
  if (snapshot.value is Map) {
    // Iterate over the children of the DataSnapshot
    (snapshot.value as Map).forEach((key, value) {
      // Add each child to the result map
      result[key] = value;
    });
  }

  return result;
}

// dynamically create form list based on # of JSON forms pulled
class MyApp extends StatelessWidget {
  final List<String> list;
  MyApp(this.list);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FormBuilder Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        FormBuilderLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: FormBuilderLocalizations.supportedLocales,
      home: CodePage(
        title: 'Dawson Forms', // page title
        child: ListView(
          children: <Widget>[
            for (String item in list) // number of forms = loop size
              Column(
                children: [
                  // creation of individual form list for UI display (ie sign inspection, road inspection, etc)
                  ListTile(
                    trailing: const Icon(Icons.arrow_right_sharp),
                    title: Text(item),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            try {
                              // Searching for the form with the name equal to item
                              Map<String, dynamic>? targetForm =
                                  separatedForms?.firstWhere(
                                (formMap) =>
                                    formMap.values.first['metadata']
                                        ['formName'] ==
                                    item,
                              );
                              final formFields = generateForm(
                                  targetForm); // This variable holds the fields of the form
                              return FormPage(
                                  formFields:
                                      formFields); // Pass formFields to the Form Page
                            } catch (e) {
                              // If the form isn't found for some reason, then print an error message
                              print('Form with the name $item not found');
                              return FormPage(); // If the form isn't found then return an empty form page
                            }
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(), // Add a Divider() after each ListTile
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Logic for form submission
void submitForm() {}

// Logic for Generating Forms
List<Widget> generateForm(Map<String, dynamic>? form) {
  List<Widget> formFields = [];

  return formFields; // Return the form fields based on the JSON data
}

class FormPage extends StatelessWidget {
  final List<Widget> formFields;

  FormPage({Key? key, this.formFields = const []}) : super(key: key);

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Page'),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding for the whole form
          children: [
            ...formFields,
            SizedBox(height: 20.0), // Space between form fields and buttons
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0), // Padding inside the button
                ),
              ),
            ),
            SizedBox(height: 12.0), // Space between buttons
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0), // Padding inside the button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class _HomePage extends StatelessWidget {
//   const _HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return CodePage(
//         title: 'Flutter Form Builder',
//         child: ListView(
//           children: list.map((String item) {
//             return ListTile(
//               title: Text(item),
//             );
//           }).toList(),
//         ));
//   }
// }
