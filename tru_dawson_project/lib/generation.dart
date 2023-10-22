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
import 'package:image_picker/image_picker.dart';
import 'package:tru_dawson_project/auth.dart';
import 'package:tru_dawson_project/google_map_field.dart';
import 'package:tru_dawson_project/picture_form.dart';
import 'package:tru_dawson_project/sign_in.dart';
import 'user_settings_page.dart';
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
              Color(0xFF234094), // Set the background color to #234094
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
                              final GlobalKey<FormBuilderState> _fbKey = GlobalKey<
                                  FormBuilderState>(); // Had to move this here in order to allow removal functionality to repeatableSections

                              List<Widget> formFields =
                                  generateForm(targetForm, _fbKey);

                              return FormPage(
                                formName: item,
                                formFields: formFields,
                                fbKey: _fbKey,
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
        color: Color(0xFF234094), // blue header in forms
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

  // Check if sections are repeatable
  if (section['type'] == "Repeatable") {
    String uniqueKey = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Generate a unique key for acquiring for the section
    repeatableSections[uniqueKey] = RepeatableSection(
        section: section,
        uniqueKey: uniqueKey,
        fbKey: fbKey); // Put the section in the map
    sectionFields.add(
        repeatableSections[uniqueKey]!); // Add the section to the ListWidget
  } else {
    for (var question in section['questions']) {
      var controlName = question['control']['meta_data']['control_name'];
      switch (question['control']['type']) {
        // More types may need to be added depending on the forms. I don't really know how to make this more dynamic for accepting anything other than something with a similar structure to the simple_sign_inspection.json
        case 'date_field': // If the type is date_field, build a date field
          {
            sectionFields.add(Column(
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
            sectionFields.add(Column(
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
            sectionFields.add(Column(
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
                        controller: SignatureController(),
                        backgroundColor: Colors.white,
                      ),
                    ))
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
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  //  final SharedPreferences prefs;
  // Map<String, dynamic> savedFormData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color(0xFF234094), // Set the background color to #234094
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
                          // formData.putIfAbsent("image", () => strUrl);
                          // bool isSubmitted = widget.onSubmit(formData);
                          widget.onSubmit(formData);
                          strUrlList = [];
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
                                      Icons
                                          .check_circle, // You can use any icon you prefer
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
                      primary: Color(0xFF6F768A),
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
                      primary: Color(0xFF6F768A),
                    ),
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

// A new widget for handling sections that are repeatable
class RepeatableSection extends StatefulWidget {
  final dynamic section;
  final String uniqueKey;
  final GlobalKey<FormBuilderState> fbKey;

  RepeatableSection(
      {required this.section,
      required this.uniqueKey,
      Key? key,
      required this.fbKey})
      : super(key: key);

  @override
  _RepeatableSectionState createState() => _RepeatableSectionState();
}

class _RepeatableSectionState extends State<RepeatableSection> {
  List<Map<String, dynamic>> repeatableFields = [];

  // List to keep track of unique identifiers for each section
  List<String> sectionIdentifiers = [];

  @override
  void initState() {
    super.initState();
    // Start with a default set of fields
    _addSection();
  }

  // Identifier will be a time string. This will ensure uniqueness everytime
  String _generateIdentifier() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Function for adding a repeatable section
  void _addSection() {
    sectionIdentifiers.add(_generateIdentifier());
    repeatableFields.add(widget.section);
  }

  // Function for removing the latest section that was added
  // void _removeSection(String key) {
  //   if (sectionIdentifiers.length > 1 && repeatableFields.length > 1) {
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       for (var question in widget.section['questions']) {
  //         // Loop through the fields of the form and remove them
  //         String controlName = question['control']['meta_data']['control_name'];
  //         String identifier = sectionIdentifiers
  //             .last; // The latest identifier since that is what will be removed.
  //         String fullName =
  //             "$controlName $identifier"; // Control name and identifier together is the name of the field
  //         if (widget.fbKey.currentState?.fields.containsKey(fullName) ??
  //             false) {
  //           // print("\n");
  //           widget.fbKey.currentState?.fields.remove(fullName);
  //         }
  //       }
  //       print(
  //           "Fields after being removed: ${widget.fbKey.currentState?.fields}");
  //     });
  //     repeatableSections.remove(key); // Remove the section from the map
  //     sectionIdentifiers.removeLast(); // Remove the field identifier
  //     repeatableFields.removeLast(); // Remove the latest section from the list
  //   }
  // } DOESN"T FUCKING WORK, ABANDON ALL YE WHO TRY TO FIX THIS

  // This function belongs to the widget and is required for regenerating sections if desired
  List<Widget> _generateRepeatableFields(
      Map<String, dynamic> section, String identifier) {
    List<Widget> repeatableFields = [];
    for (var question in section['questions']) {
      // Same logic as the generate fields functions
      var controlName = question['control']['meta_data']['control_name'];
      var fieldName =
          "${question['control']['meta_data']['control_name']} $identifier";
      switch (question['control']['type']) {
        case 'date_field': // If the type is date_field, build a date field
          {
            repeatableFields.add(Column(
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
            repeatableFields.add(Column(
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
            var controlName = question['control']['meta_data']['control_name'];
            repeatableFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controlName),
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
        case 'picture':
          {
            //get control name from JSON
            String controlName = fieldName;
            //add custom PictureWidget to the formfields with the controlName passed through to add to a title later
            repeatableFields.add(PictureWidget(controlName: fieldName));
          }
        case 'Signature': // If the type is signature, make signature box.
          {
            repeatableFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  //clipRRect to hold signature field, doesn't allow draw outside box as opposed to container
                  child: Signature(
                    height:
                        200, //you can make the field smaller by adjusting this
                    controller: SignatureController(),
                    backgroundColor: Colors.white,
                  ),
                )
              ],
            ));
            break;
          }
        case 'gps_location': // gps location! how exciting. 
          {
            repeatableFields.add(Column(
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
        default: // Add a blank text field for the default case
          {
            repeatableFields.add(Column(
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
    return repeatableFields;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < repeatableFields.length; index++)
          ..._generateRepeatableFields(
              repeatableFields[index],
              sectionIdentifiers[
                  index]), // Here the fields are added to the widget
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Optional: Align buttons to center
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _addSection();
                });
              },
              child: Icon(Icons.add),
            ),
            // SizedBox(width: 10), // Space between buttons
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       _removeSection(widget.uniqueKey);
            //     });
            //   },
            //   child: Icon(Icons.remove),
            // ),
          ],
        ),
      ],
    );
  }
}

class PictureWidget extends StatefulWidget {
  final String? controlName;
  const PictureWidget({
    super.key,
    required this.controlName,
  });
  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

String? selectedImageString;
File? selectedFile;
File? selectedFileChrome;
// String strUrl = "monkey";
List<Map<String, String>> strUrlList = [];
Future<String> photoUpload() async {
  String url = "";
  final ref =
      FirebaseStorage.instance.ref("images/" + DateTime.now().toString());
  if (!kIsWeb && selectedFile != null) {
    TaskSnapshot task = await ref.putFile(selectedFile!);
    await task;
    return await ref.getDownloadURL();
  } else if (kIsWeb && selectedFileChrome != null) {
    try {
      TaskSnapshot task =
          await ref.putData(await XFile(selectedImageString!).readAsBytes());
      return await task.ref.getDownloadURL();
    } catch (error) {
      print("Error uploading image: $error");
      return "";
    }
  } else {
    return "";
  }
}

class _PictureWidgetState extends State<PictureWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.controlName ?? "",
          textScaleFactor: 1.25,
        ),
        Row(
          children: [
            MaterialButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              color: Color(0xFF6F768A),
              textColor: Colors.white,
              child: const Text('Gallery'),
            ),
            SizedBox(
              width: 10,
              height: 10,
            ),
            MaterialButton(
                onPressed: () {
                  _pickImageFromCamera();
                },
                color: Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Camera')),
            SizedBox(width: 10, height: 10),
            //TODO clicking remove button removes photo from all upload fields
            //TODO remove does not remove from strUrlList
            MaterialButton(
                onPressed: () {
                  setState(() {
                    selectedImageString = null;
                    selectedFile = null;
                    strUrlList = [];
                  });
                },
                color: Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Remove')),
          ],
        ),
        //if the slected image string (chrome) isnt null and platform is web, get image using Image.Network, otherwise display empty sizedbox
        selectedImageString != null && kIsWeb
            ? Image.network(
                selectedImageString!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        //if selected file (ios and android) isnt null and platform is android or ios, get image using Image.file, otherwise display empty sizedbox
        selectedFile != null && !kIsWeb
            ? Image.file(
                selectedFile!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        SizedBox(width: 10, height: 10),
        MaterialButton(
            onPressed: () {
              photoUpload().then((String result) {
                setState(() {
                  // strUrl = result;
                  strUrlList.add({"name": widget.controlName!, "url": result});
                });
              });
            },
            color: Color(0xFF6F768A),
            textColor: Colors.white,
            child: const Text('Confirm Image')),
        SizedBox(height: 20)
      ],
    );
  }

  Future _pickImageFromGallery() async {
    //get image from gallery or file system
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    //make sure return image isnt null or else if we dont select a photo it will just crash
    if (returnedImage != null) {
      setState(() {
        if (!kIsWeb) {
          //get selected file when on ios or android
          selectedFile = File(returnedImage!.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          selectedFileChrome = File(returnedImage!.path);
          selectedImageString = returnedImage!.path;
        }
      });
    }
  }

  Future _pickImageFromCamera() async {
    //get image from camera (on chrome it just opens another filesystem)
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    //make sure return image isnt null or else if we dont select a photo it will just crash
    if (returnedImage != null) {
      setState(() async {
        if (!kIsWeb) {
          //get selected file when on ios or android
          selectedFile = File(returnedImage!.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          selectedFileChrome = File(returnedImage!.path);
          selectedImageString = returnedImage!.path;
        }
      });
    }
  }
}
