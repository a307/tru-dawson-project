//RUN THESE:
//flutter pub add form_builder_validators
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:tru_dawson_project/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;

// List to hold all of the individual JSONs
List<Map<String, dynamic>>? separatedForms =
    []; // List that contains each individual form

void main() async {
  //Ensures flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyChE23oQe0lYW_Y2TAKbCCjl1ox5yTikTc',
      appId: "1:203503274066:web:d1b68e01a632af4186378b",
      messagingSenderId: '203503274066',
      projectId: "tru-dawson-project-2023",
      //Must be used to connect to Firebase Realtime database
      databaseURL:
          'https://tru-dawson-project-2023-default-rtdb.firebaseio.com/',
      storageBucket: "gs://tru-dawson-project-2023.appspot.com",
    ));
  } else if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyChE23oQe0lYW_Y2TAKbCCjl1ox5yTikTc',
      appId: "1:203503274066:web:d1b68e01a632af4186378b",
      messagingSenderId: '203503274066',
      projectId: "tru-dawson-project-2023",
      //Must be used to connect to Firebase Realtime database
      databaseURL:
          'https://tru-dawson-project-2023-default-rtdb.firebaseio.com/',
      storageBucket: "gs://tru-dawson-project-2023.appspot.com",
    ));
  } else {
    if (!(Firebase.apps.isEmpty)) {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
        apiKey: 'AIzaSyChE23oQe0lYW_Y2TAKbCCjl1ox5yTikTc',
        appId: "1:203503274066:web:d1b68e01a632af4186378b",
        messagingSenderId: '203503274066',
        projectId: "tru-dawson-project-2023",
        //Must be used to connect to Firebase Realtime database
        databaseURL:
            'https://tru-dawson-project-2023-default-rtdb.firebaseio.com/',
        storageBucket: "gs://tru-dawson-project-2023.appspot.com",
      ));
    } else {
      Firebase.initializeApp(); // if already initialized, use that one
    }
  }

  //Initialize Firebase

  // FirebaseDatabase.instance.setPersistenceEnabled(true); // commented this out as chrome says it does not support it?
  //Run Application starting with Generator as home
  // runApp(MaterialApp(home: Generator(list, separatedForms) //class
  //     ));
  LocationPermission permission;
  permission = await Geolocator.requestPermission();
  runApp(const MaterialApp(
    home: SignIn(), //class
    debugShowCheckedModeBanner: false,
  ));
}
