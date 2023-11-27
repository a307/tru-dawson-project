import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:signature/signature.dart';
import 'package:tru_dawson_project/generation.dart';
import 'package:tru_dawson_project/repeatable_section.dart';
import 'package:tru_dawson_project/section.dart';
import 'package:tru_dawson_project/google_map_field.dart';
import 'picture_widget.dart';

class FormPage extends StatefulWidget {
  List<Widget> formFields;
  final String formName;
  final String globalEmail;
  final GlobalKey<FormBuilderState> fbKey;
  SignatureController signatureController;
  List<Map<String, String>> signatureURL;
  //create onsubmit function so when we create a FormPage later in Generator we can use an onsubmit function to send the data to firebase
  final Function(Map<String, dynamic>) onSubmit;
  FormPage({
    Key? key,
    required this.formFields,
    required this.globalEmail,
    required this.formName,
    required this.onSubmit,
    required this.fbKey,
    required this.signatureURL,
    required this.signatureController,
  }) : super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
// When the back button is pressed, display an alert dialog
  Future<bool> onBackPressed() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Do you want to go back? Changes will be lost.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(false), // Dismiss dialog and do not leave the page
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // If Yes is selected
              extraIdentifier = 0;
              repeatableSectionExtraIdentifier = 100;
              strUrlList.clear();
              widget.signatureURL.clear();
              signatureController.clear();
              currentLoc = const LatLng(0, 0);

              Navigator.of(context).pop(true);
            }, // Dismiss dialog and leave the page
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(
              192, 2, 5, 1), // Set the background color to #234094
          title: Text(widget.formName),
        ),
        body: FormBuilder(
          key: widget.fbKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              ...widget.formFields,
              const SizedBox(height: 20.0),
              SizedBox(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        bool isValid =
                            widget.fbKey.currentState?.saveAndValidate() ??
                                false;

                        if (isValid) {
                          Map<String, dynamic>? formData =
                              widget.fbKey.currentState?.value ?? {};
                          // Map<String, dynamic>? formDataWithUniqueIds = {};

                          // int extraIdentifier = 0;
                          // formData.forEach((key, value) {
                          //   // Append an extra identifier to each field in order to display the fields in the proper order in view past forms
                          //   formDataWithUniqueIds['$key $extraIdentifier'] =
                          //       value;
                          //   extraIdentifier++;
                          // });

                          print("On submission: $formData");
                          formData = Map<String, dynamic>.from(formData);
                          for (var element in strUrlList) {
                            formData.putIfAbsent(
                                element['name']!, () => element['url']);
                          }
                          for (var element in widget.signatureURL) {
                            formData.putIfAbsent(
                                element['name']!, () => element['url']);
                          }
                          LatLng loc = const LatLng(0, 0);
                          if (currentLoc != loc) {
                            formData.putIfAbsent(
                                "Current Location",
                                () =>
                                    "${currentLoc.latitude}, ${currentLoc.longitude}");
                          }
                          // formData.putIfAbsent("image", () => strUrl);
                          // bool isSubmitted = widget.onSubmit(formData);
                          widget.onSubmit(formData);
                          strUrlList.clear();
                          widget.signatureURL.clear();
                          signatureController.clear();
                          // Reset Identifers after submission
                          extraIdentifier = 0;
                          repeatableSectionExtraIdentifier = 100;
                          currentLoc = const LatLng(0, 0);
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
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                                                  //}
                        } else {
                          print('Form validation failed.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(192, 2, 5, 1),
                        minimumSize: const Size(250, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              24), // Adjust the radius for roundness
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        // Reset Identifers after submission
                        extraIdentifier = 0;
                        repeatableSectionExtraIdentifier = 100;
                        widget.signatureController.clear();
                        Navigator.of(context).pop();
                        strUrlList.clear();
                        widget.signatureURL.clear();
                        signatureController.clear();
                        currentLoc = const LatLng(0, 0);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(192, 2, 5, 1),
                          minimumSize: const Size(250, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          )),
                      child: const Text('Go Back'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
