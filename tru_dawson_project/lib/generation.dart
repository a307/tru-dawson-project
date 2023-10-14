//RUN THESE:
//flutter pub add form_builder_validators
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/picture_form.dart';
import 'package:tru_dawson_project/sign_in.dart';

// List to hold all of the individual JSONs
List<Map<String, dynamic>>? separatedForms =
    []; // List that contains each individual form

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

  return result as Map<String, dynamic>;
}

dynamic globalResult;

// dynamically create form list based on # of JSON forms pulled
class Generator extends StatelessWidget {
  final List<String> list;
  List<Map<String, dynamic>>? separatedForms;
  dynamic result;
  AuthService auth;
  Generator(this.list, this.separatedForms, this.result, this.auth) {
    globalResult = result;
  }

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
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF234094), // Set the background color to #234094
          title: const Text('Dawson Forms'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                Navigator.of(context).pop();
                auth.SignOut();
              },
            ),
          ],
        ),
        body: ListView(
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
                              Map<String, dynamic>? targetForm =
                                  separatedForms?.firstWhere((formMap) {
                                return formMap['metadata']['formName'] == item;
                              });

                              List<Widget> formFields =
                                  generateForm(targetForm);

                              return FormPage(
                                formName: item,
                                formFields: formFields,
                                onSubmit: (formData) {
                                  print('Form Data: $formData');
                                  print('Submitting form data to Firebase...');
                                  final CollectionReference collection =
                                      FirebaseFirestore.instance
                                          .collection(item);
                                  submitFormToFirebase(formData, collection);
                                },
                              );
                            } catch (e) {
                              print('$e Something Went wrong');
                              return FormPage(
                                formName: '',
                                onSubmit: (formData) {
                                  print('Form Data: $formData');
                                  print('Submitting form data to Firebase...');
                                  final CollectionReference collection =
                                      FirebaseFirestore.instance
                                          .collection(item);
                                  submitFormToFirebase(formData, collection);
                                },
                              );
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
        children: [Text(label, textScaleFactor: 1.25), SizedBox(height: 10)],
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
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                       ),
                      ),
                      inputType: InputType.date,
                  ),
                   SizedBox(height: 10),
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
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                       ),
                      ),
                  ),
                  SizedBox(height: 20)
                ],
              ));
              break;
            }
          case 'Dropdown':
            {
              var options = question['control']['meta_data']['options'];
              var controlName = question['control']['meta_data']['control_name'];
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controlName),
                  SizedBox(height: 10),
                  FormBuilderDropdown(
                    name: controlName,
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: options.map<DropdownMenuItem<String>>((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
              ));
              break;
            }
          case 'picture':
            {
              String controlName =
                  question['control']['meta_data']['control_name'];
              formFields.add(PictureWidget(controlName: controlName));
            }
          default: // Add a blank text field for the default case
            {
              formFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: 'FILL',
                    decoration: const InputDecoration(labelText: ''),
                  ),
                  
                  SizedBox(height: 10),
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

void submitFormToFirebase(
  Map<String, dynamic> formData,
  CollectionReference collection,
) async {
  // Initialize the Firebase database reference
  final databaseReference = FirebaseDatabase.instance.ref();

  return await collection.doc(globalResult.uid).set(formData);
}

class FormPage extends StatefulWidget {
  final List<Widget> formFields;
  final String formName;
  final Function(Map<String, dynamic>) onSubmit;

  FormPage({
    Key? key,
    this.formFields = const [],
    required this.formName,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF234094), // Set the background color to #234094
        title: Text(widget.formName),
      ),
      body: FormBuilder(
        key: _fbKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            ...widget.formFields,
            SizedBox(height: 20.0),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  bool isValid =
                      _fbKey.currentState?.saveAndValidate() ?? false;

                  if (isValid) {
                    Map<String, dynamic>? formData = _fbKey.currentState?.value;
                    if (formData != null) {
                      widget.onSubmit(formData);
                    }
                  } else {
                    print('Form validation failed.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6F768A),
                  minimumSize: Size(72, 36),
                ),
                child: Text('Submit'),
              ),
            ),
            SizedBox(height: 12.0),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6F768A),
                  minimumSize: Size(72, 36),
                ),
                child: Text('Go Back'),
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
