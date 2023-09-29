//RUN THESE:
//flutter pub add form_builder_validators
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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

void main() async {
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
  final snapshot = await ref.child('forms').get();
  //Print data out if there is any
  if (snapshot.exists) {
    print(snapshot.value);
  } else {
    print('No data available.');
  }
  //Run Application starting with MyApp as home
  runApp(const MaterialApp(home: MyApp() //class
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter FormBuilder Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        FormBuilderLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: FormBuilderLocalizations.supportedLocales,
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CodePage(
      title: 'Flutter Form Builder',
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Complete Form'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Complete Form',
                      child: CompleteForm(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Custom Fields'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Custom Fields',
                      child: CustomFields(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Signup Form'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Signup Form',
                      child: SignupForm(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Dynamic Form'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Dynamic Form',
                      child: DynamicFields(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Conditional Form'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Conditional Form',
                      child: ConditionalFields(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Related Fields'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Related Fields',
                      child: RelatedFields(),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Test Form'),
            trailing: const Icon(Icons.arrow_right_sharp),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CodePage(
                      title: 'Test Form',
                      child: RelatedFields(),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
