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
List<Map<String, dynamic>>? separatedForms =
    []; // List that contains each individual form

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
                      // Everything that occurs here happens when one of the items is clicked/tapped on
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            try {
                              // Searching for the form with the name equal to item
                              Map<String, dynamic>? targetForm =
                                  separatedForms?.firstWhere((formMap) {
                                // Will find the first instance of a form that has the same name as item
                                return formMap['metadata']['formName'] ==
                                    item; // If this statement is true then it was a success and the following code will execute
                              });
                              final formFields = generateForm(
                                  targetForm); // This variable holds the fields of the form after the generateForm function runs
                              return FormPage(
                                  formName: item,
                                  formFields:
                                      formFields); // Pass formFields to the Form Page
                            } catch (e) {
                              // If the form isn't found or something happens during the building, then an error message will display
                              print('Something Went wrong');
                              return FormPage(
                                formName: '',
                              ); // If the form isn't found then return an empty form page with no name
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
// This is made under the assumption that the dawson forms will all have a similar JSON structure to the simple_sign_inspection.json containing pages, sections, and questions
List<Widget> generateForm(Map<String, dynamic>? form) {
  List<Widget> formFields = [];

  for (var page in form?['pages']) {
    // Loop through the pages
    // Loop through the pages in the form
    for (var section in page['sections']) {
      // Loop through the sections
      // Loop through the sections on each page
      var label =
          section['label']; // Store the label for the section in the variable
      formFields.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
        ],
      ));
      for (var question in section['questions']) {
        var controlName = question['control']['meta_data']['control_name'];
        switch (question['control']['type']) {
          // More types may need to be added depending on the forms. I don't really know how to make this more dynamic for accepting anything other than something with a similar structure to the simple_sign_inspection.json
          case 'date_field': // If the type is date_field, build a date field
            {
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderDateTimePicker(
                    name: controlName,
                    decoration: InputDecoration(labelText: controlName),
                    inputType: InputType.date,
                  )
                ],
              ));
              break;
            }
          case 'text_field': // If the type is text_field, build a date field
            {
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: controlName,
                    decoration: InputDecoration(labelText: controlName),
                  )
                ],
              ));
              break;
            }
          case 'Dropdown': // If the type is Dropdown, build a dropdown field
            {
              var options = question['control']['meta_data'][
                  'options']; // This variable stores the options in the dropdown menu
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderDropdown(
                    name: controlName,
                    items: options.map<DropdownMenuItem<String>>((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  )
                ],
              ));
              break;
            }
          default: // Add a blank text field for the default case
            {
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: '',
                    decoration: const InputDecoration(labelText: ''),
                  )
                ],
              ));
              break;
            }
        }
      }
    }
  }
  return formFields; // Return the form fields based on the JSON data
}

class FormPage extends StatelessWidget {
  final List<Widget> formFields;

  final String formName;

  FormPage({Key? key, this.formFields = const [], required this.formName})
      : super(
            key:
                key); // This is required for building the formFields and getting the form name

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formName),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding for the whole form
          children: [
            ...formFields, // This is where the form fields will go in the formPage widget when it is built
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
