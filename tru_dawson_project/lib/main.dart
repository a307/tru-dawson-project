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
import 'package:tru_dawson_project/generation.dart';
import 'package:tru_dawson_project/sign_in.dart';

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
  //Run Application starting with Generator as home
  // runApp(MaterialApp(home: Generator(list, separatedForms) //class
  //     ));
  runApp(MaterialApp(home: SignIn() //class
      ));
}
