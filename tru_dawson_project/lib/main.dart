import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';

class FormGenerator extends StatefulWidget {
  const FormGenerator({super.key});

  @override
  State<FormGenerator> createState() => _FormGeneratorState();
}

class _FormGeneratorState extends State<FormGenerator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(
            child: Text('Simple Form Generator from JSON'),
          ),
          const Expanded(
            flex: 4,
            child: Text('Placeholder'),
          ),
          Expanded(
            child: Center(
              child: MaterialButton(
                color: Colors.blue,
                onPressed: () {},
                child: const Text('Generate Form'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
