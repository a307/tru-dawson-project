import 'package:flutter/material.dart';

class FormFieldWidget extends StatelessWidget {
  final name;
  final value;

  const FormFieldWidget({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    String fieldName = name.toString();
    List<String> splitName = fieldName.split(' ');
    String fieldNameType = splitName[0];
    RegExp pattern = RegExp(
        'signature'); // Pattern for detecting a signature field, since in the firestore database the field name is 'signature[0]'

    if (pattern.hasMatch(fieldNameType)) {
      fieldNameType = 'Signature';
    }

    if (fieldNameType == 'Signature' || fieldNameType == 'image') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$fieldName:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Image.network(
            '$value',
            width: 250,
            height: 150,
            fit: BoxFit.cover,
          )
        ],
      );
    } else {
      String content = value.toString();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$fieldName: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
    }
  }
}
