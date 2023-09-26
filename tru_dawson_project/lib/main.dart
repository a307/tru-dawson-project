import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FormGenerator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FormGenerator extends StatefulWidget {
  const FormGenerator({Key? key}) : super(key: key);

  @override
  State<FormGenerator> createState() => _FormGeneratorState();
}

class _FormGeneratorState extends State<FormGenerator> {
  List _items = [];

  void generateForm() async {
    final String response =
        await rootBundle.loadString('assets/text_field.json');
    final data = await json.decode(response);
    setState(() {
      _items = [data];
      print("number of items ${_items.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Generate Forms from JSON'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 4,
            child: Center(
              child: Text('Placeholder'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: MaterialButton(
                color: Colors.blue,
                onPressed: () => {generateForm()},
                child: const Text('Generate Form'),
                textColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
