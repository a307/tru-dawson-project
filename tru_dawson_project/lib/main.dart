import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for rootBundle to read files
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:convert'; // Required for JSON operations

// Entry point of the app (Didn't know what this meant before)
void main() => runApp(const MyApp());

// Root Widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp provides Material Theming for the app (Didn't know what this meant before)
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This removes the debug banner from
      home: MyHomePage(),
    );
  }
}

// StatefulWidget allows UI to be rebuilt when state changes (Didn't know what this meant before)
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// State class where logic and variables are defined
class _MyHomePageState extends State<MyHomePage> {
  // Key used to access form state and then validate (Kind of understand this but not completely)
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  // Variable to determine if form should be shown
  bool showForm = false;

  // Map to hold parsed JSON data
  Map<String, dynamic> jsonMap = {};

  // Initialize state: this method is called once when the widget is displayed
  @override
  void initState() {
    super.initState();
    // Load JSON from assets folder and then update state
    _loadJsonFromAssets().then((value) {
      setState(() {
        jsonMap = value;
      });
    });
  }

  // Function to load and decode JSON from asset folder
  Future<Map<String, dynamic>> _loadJsonFromAssets() async {
    String jsonString = await rootBundle.loadString('assets/text_field.json');
    return jsonDecode(jsonString);
  }

  // Build method for constructing the UI
  @override
  Widget build(BuildContext context) {
    List<Widget> formFields = [];

    // Check conditions to determine if FormBuilderTextField should be added
    if (showForm && jsonMap['type'] == 'text_field') {
      // If showForm is true and the type is text_field
      // The type is text field so a text field will be generated
      formFields.add(FormBuilderTextField(
        name: jsonMap['meta_data'][
            'control_name'], // This sets the name of the TextField and it's type of data. In this case the name of it will be the value of "control_name" which is "String" in the meta_data map (I'm still confused with what the meta_data represents)
        decoration: const InputDecoration(
            labelText:
                'Text Field'), // This is placeholder or "hint" text for the text field
      ));
    }

    // Returns the overall layout of this screen
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Form Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button to generate the form
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (showForm == true) {
                      showForm = false;
                    } else {
                      showForm = true;
                    }
                  });
                },
                child: const Text('Generate Form'),
              ),
            ),
            // If showForm is true, show the form. Otherwise, show an empty container.
            Expanded(
              child: showForm
                  ? FormBuilder(
                      key: _fbKey,
                      child: ListView(children: formFields),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
