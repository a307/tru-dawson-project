//RUN THESE:
//flutter pub add form_builder_validators
//flutter pub add signature
// ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/google_map_field.dart';
import 'package:tru_dawson_project/sign_in.dart';
import 'user_settings_page.dart';
import 'picture_widget.dart';
import 'repeatable_section.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import 'package:signature/signature.dart';
// List to hold all of the individual JSONs

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

//Make signature cnroller to be called later
SignatureController _controller = SignatureController(
  penColor: Colors.black, //can adjust parameters in here if you like
  penStrokeWidth: 5.0,
);

dynamic globalResult;
String globalEmail = "";

// dynamically create form list based on # of JSON forms pulled
class Generator extends StatelessWidget {
  final List<String> list;
  List<Map<String, dynamic>>? separatedForms;
  dynamic result;
  AuthService auth;
  String email;
  Generator(
      this.list, this.separatedForms, this.result, this.auth, this.email) {
    globalResult = result;
    globalEmail = email;
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
          backgroundColor:
              Color(0xFFC00205), // Set the background color to #234094
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
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'User Settings',
              onPressed: () {
                // Navigate to the User Settings page when the gear icon is pressed
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserSettingsPage(),
                  ),
                );
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
                              final GlobalKey<FormBuilderState> fbKey =
                                  GlobalKey<FormBuilderState>();

                              List<Widget> formFields =
                                  generateForm(targetForm, fbKey);

                              print(targetForm);

                              return FormPage(
                                formName: item,
                                formFields: formFields,
                                fbKey: fbKey,
                                //onsubmit function mentioned in FormPage, allows us to pass the data from the form into a a firebase submission function
                                onSubmit: (formData) {
                                  print('Form Data: $formData');
                                  print('Submitting form data to Firebase...');
                                  //get collection with name as the form name (item)
                                  final CollectionReference collection =
                                      FirebaseFirestore.instance
                                          .collection(item);
                                  //pass formData and collection to submission function
                                  submitFormToFirebase(formData, collection);
                                },
                              );
                            } catch (e, stacktrace) {
                              print('$e Something Went wrong');
                              //print('Stacktrace: ' + stacktrace.toString());
                              return FormPage(
                                formFields: [],
                                formName: '',
                                fbKey: GlobalKey<FormBuilderState>(),
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

// Logic for Generating Forms
// This is made under the assumption that the dawson forms will all have a similar JSON structure to the simple_sign_inspection.json containing pages, sections, and questions
List<Widget> generateForm(
    Map<String, dynamic>? form, GlobalKey<FormBuilderState> fbKey) {
  List<Widget> formFields = [];

  //print(form);

  for (var page in form?['pages']) {
    // Loop through the pages in the form
    for (var section in page['sections']) {
      formFields.addAll(generateSection(convertToMap(section), fbKey));
      // Loop through the sections on each page
    }
  }
  return formFields; // Return the form fields based on the JSON data
}

Map<String, Widget> repeatableSections =
    {}; // Map that stores unique identifiers for each widget

// Function for handling section generation
List<Widget> generateSection(
    Map<String, dynamic> section, GlobalKey<FormBuilderState> fbKey) {
  List<Widget> sectionFields = [];
  // Loop through the sections on each page
  var label =
      section['label']; // Store the label for the section in the variable
  sectionFields.add(Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Color(0xFFC00205), // Red header in forms
          borderRadius:
              BorderRadius.circular(12.0), // Adjust the radius for rounding
          boxShadow: [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 2), // Shadow offset
              blurRadius: 4, // Shadow blur radius
            ),
          ],
        ),
        child: Text(
          label,
          textScaleFactor: 1.25,
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
      ),
      SizedBox(height: 10)
    ],
  ));
  String uniqueKey = DateTime.now()
      .millisecondsSinceEpoch
      .toString(); // Generate a unique key for acquiring for the section
  // Check if sections are repeatable
  if (section['type'] == "Repeatable") {
    repeatableSections[uniqueKey] = RepeatableSection(
        section: section,
        uniqueKey: uniqueKey,
        fbKey: fbKey); // Put the section in the map
    sectionFields.add(
        repeatableSections[uniqueKey]!); // Add the section to the ListWidget
  } else {
    for (var question in section['questions']) {
      var controlName = question['control']['meta_data']['control_name'];
      var fieldName = "$controlName $uniqueKey";
      switch (question['control']['type']) {
        // More types may need to be added depending on the forms. I don't really know how to make this more dynamic for accepting anything other than something with a similar structure to the simple_sign_inspection.json
        case 'date_field': // If the type is date_field, build a date field
          {
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderDateTimePicker(
                  name: fieldName,
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
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: fieldName,
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
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                FormBuilderDropdown(
                  name: fieldName,
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
        case 'multiselect':
          {
            var options = question['control']['meta_data']['options']
                as List<dynamic>; // Cast options to List<dynamic>
            List<String> optionsList = [];
            if (options.length == 1) {
              // If there is only one element in the list (i.e. one string that contains all the options)
              // If options in the JSON is represented as one string, then it will need to be split
              optionsList = (options[0] as String)
                  .split(', '); // Cast options[0] to String
              sectionFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  FormBuilderCheckboxGroup(
                    name: fieldName,
                    options: optionsList
                        .map((option) => FormBuilderFieldOption(
                            value: option as String, // Cast option to String
                            child: Text(
                                option as String))) // Cast option to String
                        .toList(),
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ));
            } else {
              // If there are multiple elements in options
              sectionFields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  FormBuilderCheckboxGroup(
                    name: fieldName,
                    options: optionsList
                        .map((option) => FormBuilderFieldOption(
                            value: option as String, // Cast option to String
                            child: Text(
                                option as String))) // Cast option to String
                        .toList(),
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ));
            }
            break;
          }
        case 'picture':
          {
            //get control name from JSON
            String controlName =
                question['control']['meta_data']['control_name'];
            //add custom PictureWidget to the formfields with the controlName passed through to add to a title later
            sectionFields.add(PictureWidget(controlName: controlName));
          }
        case 'Signature': // If the type is signature, make signature box.
          {
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please provide your signature:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          // Outline color
                          //  width: 2.0, // Outline width
                        ),
                      ),
                      //clipRRect to hold signature field, doesn't allow draw outside box as opposed to container
                      child: Signature(
                        height:
                            200, //you can make the field smaller by adjusting this
                        controller: _controller,
                        backgroundColor: Colors.white,
                      ),
                    )),
                Row(
                  children: [
                    IconButton(
                        tooltip: "Confirm your signature",
                        onPressed: () async {
                          if (_controller.isNotEmpty) {
                            final signature = await exportSignature();
                          }
                        },
                        icon: Icon(Icons.check),
                        color: Colors.green),
                    IconButton(
                        tooltip: "Clear your signature",
                        onPressed: () {
                          _controller.clear();
                          //TODO: fix removing all signatures
                          signatureURL = [];
                        },
                        icon: Icon(Icons.clear),
                        color: Colors.red),
                  ],
                )
              ],
            ));
            break;
          }
        case 'checkbox':
          {
            List<String> optionsList = ["True", "False"];
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                FormBuilderRadioGroup(
                  name: fieldName,
                  options: optionsList
                      .map((option) => FormBuilderFieldOption(
                            value: option as String,
                            child: Text(option as String),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: controlName,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ));
            break;
          }
        case 'gps_location': // gps location! how exciting.
          {
            sectionFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pin is on your current location. Drag pin to edit.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          // Outline color
                          //  width: 2.0, // Outline width
                        ),
                      ),
                      //map :O
                      child: MapField(),
                    ))
              ],
            ));
            break;
          }
        case 'label': // If the type is a label, display some text.
          {
            var labelName;
            var labelType;
            var labelText;
            if (question['control']['meta_data'].containsKey('meta_data')) {
              // In the label section of fuel_inspection.json, there is a nested field with two metadata keys. This may be a mistake, but I will account for it here in case it pops up again in other forms
              labelName =
                  question['control']['meta_data']['meta_data']['control_name'];
              labelType =
                  question['control']['meta_data']['meta_data']['label_type'];
              labelText =
                  question['control']['meta_data']['meta_data']['control_text'];
            } else {
              labelName = controlName;
              labelType = question['control']['meta_data']['label_type'];
              labelText = question['control']['meta_data']['control_text'];
            }
            switch (labelType) {
              // The text would be presented differently depending on the label type, more cases will need to be added if new styles show up in different forms
              case "bold": // Text will be bold
                {
                  sectionFields.add(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 36),
                      ),
                      Text(
                        labelText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ));
                  break;
                }
              default: // Default case no styling
                {
                  sectionFields.add(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelName,
                      ),
                      Text(
                        labelText,
                      ),
                    ],
                  ));
                  break;
                }
            }
            break;
          }
        default: // Add a blank text field for the default case
          {
            sectionFields.add(Column(
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

  return sectionFields;
}

List<Map<String, String>> signatureURL = [];
Future<void> exportSignature() async {
  int len = signatureURL.length;
  signatureURL.add(
      {"name": "signature$len", "url": await signatureUpload(_controller)});
}

Future<String> signatureUpload(SignatureController signature) async {
  String url = "";
  final ref =
      FirebaseStorage.instance.ref("images/" + DateTime.now().toString());

  try {
    TaskSnapshot task = await ref.putData((await signature.toPngBytes())!);
    return await task.ref.getDownloadURL();
  } catch (error) {
    print("Error uploading image: $error");
    return "";
  }
}

void submitFormToFirebase(
  Map<String, dynamic> formData,
  CollectionReference collection,
) async {
  // Initialize the Firebase database reference
  final databaseReference = FirebaseDatabase.instance.ref();
  //send data to the database with UID and formdata
  return collection
      .doc(globalEmail + "--" + DateTime.now().toString())
      .set(formData);
}

class FormPage extends StatefulWidget {
  List<Widget> formFields;
  final String formName;
  final GlobalKey<FormBuilderState> fbKey;
  //create onsubmit function so when we create a FormPage later in Generator we can use an onsubmit function to send the data to firebase
  final Function(Map<String, dynamic>) onSubmit;
  FormPage({
    Key? key,
    required this.formFields,
    required this.formName,
    required this.onSubmit,
    required this.fbKey,
  }) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormBuilderState> fbKey = GlobalKey<FormBuilderState>();
  //  final SharedPreferences prefs;
  // Map<String, dynamic> savedFormData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color(0xFFC00205), // Set the background color to #234094
        title: Text(widget.formName),
      ),
      body: FormBuilder(
        key: widget.fbKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            ...widget.formFields,
            SizedBox(height: 20.0),
            SizedBox(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      bool isValid =
                          widget.fbKey.currentState?.saveAndValidate() ?? false;

                      if (isValid) {
                        Map<String, dynamic>? formData =
                            widget.fbKey.currentState?.value ?? {};
                        print("On submission: $formData");
                        if (formData != null) {
                          formData = Map<String, dynamic>.from(formData);
                          for (var element in strUrlList) {
                            formData.putIfAbsent(
                                element['name']!, () => element['url']);
                          }
                          for (var element in signatureURL) {
                            formData.putIfAbsent(
                                element['name']!, () => element['url']);
                          }
                          // formData.putIfAbsent("image", () => strUrl);
                          // bool isSubmitted = widget.onSubmit(formData);
                          widget.onSubmit(formData);
                          strUrlList = [];
                          signatureURL = [];
                          // if (isSubmitted) {
                          // Form submission successful
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      // green check icon
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 48.0,
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Form Submission Successful',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12.0),
                                    Text(
                                      'Your form has been submitted successfully.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the alert dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        //}
                      } else {
                        print('Form validation failed.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFC00205),
                      minimumSize: Size(250, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            24), // Adjust the radius for roundness
                      ),
                    ),
                    child: Text('Submit'),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.0),
            SizedBox(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      strUrlList = [];
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFC00205),
                        minimumSize: Size(250, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        )),
                    child: Text('Go Back'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function used to find whether a key exists. This is needed for repeatableSection removal
bool keyExists(String key, Map<String, dynamic> map) {
  return map.containsKey(key);
}
