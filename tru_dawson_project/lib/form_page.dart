import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:signature/signature.dart';
import 'package:tru_dawson_project/generation.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                          for (var element in widget.signatureURL) {
                            formData.putIfAbsent(
                                element['name']!, () => element['url']);
                          }
                          formData.putIfAbsent(
                              "Current Location",
                              () =>
                                  currentLoc.latitude.toString() +
                                  ", " +
                                  currentLoc.longitude.toString());
                          // formData.putIfAbsent("image", () => strUrl);
                          // bool isSubmitted = widget.onSubmit(formData);
                          widget.onSubmit(formData);
                          strUrlList.clear();
                          widget.signatureURL.clear();
                          signatureController.clear();
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
                      widget.signatureController.clear();
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