//RUN THESE:
//flutter pub add form_builder_validators
//flutter pub add signature
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/sign_in.dart';
import 'package:tru_dawson_project/view_past_forms.dart';
import 'user_settings_page.dart';
import 'repeatable_section.dart';
import 'section.dart';
import 'form_page.dart';
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

  return result;
}

dynamic globalResult;
String globalEmail = "";
List<String> globallist = [];

// dynamically create form list based on # of JSON forms pulled
class Generator extends StatelessWidget {
  final List<String> list;
  List<Map<String, dynamic>>? separatedForms;
  dynamic result;
  AuthService auth;
  String email;
  Generator(this.list, this.separatedForms, this.result, this.auth, this.email,
      {super.key}) {
    //assign globals for using in other widgets
    globalResult = result;
    globalEmail = email;
    globallist = list;
  }

  @override
  Widget build(BuildContext context) {
    //listens for back button presses
    return WillPopScope(
      //if back button on phone is pressed trigger this function
      onWillPop: () async {
        //clear list and separated form data
        list.clear();
        separatedForms!.clear();
        return true;
      },
      child: MaterialApp(
        title: 'Dawson Group Reporting App', //made name not demo text haha
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
                const Color(0xFFC00205), // Set the background color to #234094
            title: const Text('Dawson Forms'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: () {
                  Navigator.of(context).pop();
                  list.clear();
                  separatedForms!.clear();
                  auth.SignOut();
                },
              ),
              IconButton(
                // user setting icon
                icon: const Icon(Icons.settings),
                tooltip: 'User Settings',
                onPressed: () {
                  // Navigate to the User Settings page when the gear icon is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserSettingsPage(),
                    ),
                  );
                },
              ),
              IconButton(
                // view past forms icon
                icon: const Icon(Icons.access_time),
                tooltip: 'View Past Forms',
                onPressed: () {
                  //ViewPastForms vpf = ViewPastForms();
                  //vpf.getFormData('Equipment Inspection');
                  // Navigate to the User Settings page when the gear icon is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewPastForms(globalEmail: globalEmail),
                      //builder: (context) => ViewPastForms(),
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
                                  return formMap['metadata']['formName'] ==
                                      item;
                                });
                                final GlobalKey<FormBuilderState> fbKey =
                                    GlobalKey<FormBuilderState>();

                                List<Widget> formFields =
                                    generateForm(targetForm, fbKey);

                                return FormPage(
                                  formName: item,
                                  formFields: formFields,
                                  fbKey: fbKey,
                                  globalEmail: globalEmail,
                                  signatureURL: signatureURL,
                                  signatureController: signatureController,
                                  //onsubmit function mentioned in FormPage, allows us to pass the data from the form into a a firebase submission function
                                  onSubmit: (formData) {
                                    print('Form Data: $formData');
                                    print(
                                        'Submitting form data to Firebase...');
                                    //get collection with name as the form name (item)
                                    final CollectionReference collection =
                                        FirebaseFirestore.instance
                                            .collection(item);
                                    //pass formData and collection to submission function
                                    submitFormToFirebase(formData, collection);
                                  },
                                );
                              } catch (e) {
                                print('$e Something Went wrong');
                                //print('Stacktrace: ' + stacktrace.toString());
                                //if error, initialize formpage with empty data
                                return FormPage(
                                  formFields: [],
                                  formName: '',
                                  globalEmail: '',
                                  signatureURL: [],
                                  signatureController: SignatureController(),
                                  fbKey: GlobalKey<FormBuilderState>(),
                                  //provide onsubmit function for FormPage
                                  onSubmit: (formData) {
                                    print('Form Data: $formData');
                                    print(
                                        'Submitting form data to Firebase...');
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
      ),
    );
  }
}

// Logic for Generating Forms
// This is made under the assumption that the dawson forms will all have a similar JSON structure to the simple_sign_inspection.json containing pages, sections, and questions
List<Widget> generateForm(
    Map<String, dynamic>? form, GlobalKey<FormBuilderState> fbKey) {
  List<Widget> formFields = [];

  for (var page in form?['pages']) {
    // Loop through the pages in the form
    for (var section in page['sections']) {
      formFields.addAll(generateSection(convertToMap(section), fbKey));
      // Loop through the sections on each page
    }
  }
  return formFields; // Return the form fields based on the JSON data
}

Map<String, Widget> sections =
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
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFC00205), // Red header in forms
          borderRadius:
              BorderRadius.circular(12.0), // Adjust the radius for rounding
          boxShadow: [
            const BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 2), // Shadow offset
              blurRadius: 4, // Shadow blur radius
            ),
          ],
        ),
        child: Text(
          label,
          textScaleFactor: 1.25,
          style: const TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
      ),
      const SizedBox(height: 10)
    ],
  ));
  String uniqueKey = DateTime.now()
      .millisecondsSinceEpoch
      .toString(); // Generate a unique key for acquiring for the section
  // Check if sections are repeatable
  if (section['type'] == "Repeatable") {
    sections[uniqueKey] = RepeatableSection(
        section: section,
        uniqueKey: uniqueKey,
        fbKey: fbKey); // Put the section in the map
    sectionFields
        .add(sections[uniqueKey]!); // Add the section to the ListWidget
  } else {
    // Add a normal section widget that isn't repeatable
    sections[uniqueKey] = Section(
      section: section,
      uniqueKey: uniqueKey,
      fbKey: fbKey,
    );
    sectionFields.add(sections[uniqueKey]!);
  }

  return sectionFields;
}

//Make signature cnroller to be called later
SignatureController signatureController = SignatureController(
  penColor: Colors.black, //can adjust parameters in here if you like
  penStrokeWidth: 5.0,
);

List<Map<String, String>> signatureURL = [];

Future<String> signatureUpload(SignatureController signature) async {
  String url = "";
  final ref = FirebaseStorage.instance.ref("images/${DateTime.now()}");

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
  return collection.doc("$globalEmail--${DateTime.now()}").set(formData);
}
