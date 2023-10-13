import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tru_dawson_project/auth.dart';

class PictureWidget extends StatefulWidget {
  final String? controlName;
  const PictureWidget({
    super.key,
    required this.controlName,
  });
  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

class _PictureWidgetState extends State<PictureWidget> {
  String? _selectedImageString;
  File? _selectedFile;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.controlName ?? "",
          textScaleFactor: 1.1,
        ),
        Row(
          children: [
            MaterialButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              color: Colors.blue,
              child: const Text('Pick from Gallery'),
            ),
            SizedBox(width: 10),
            MaterialButton(
                onPressed: () {
                  _pickImageFromCamera();
                },
                color: Colors.blue,
                child: const Text('Take Photo with Camera')),
          ],
        ),
        _selectedImageString != null && kIsWeb
            ? Image.network(
                _selectedImageString!,
                fit: BoxFit.contain,
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        _selectedFile != null &&
                    defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? Image.file(
                _selectedFile!,
                fit: BoxFit.contain,
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        SizedBox(height: 20)
      ],
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        _selectedFile = File(returnedImage!.path);
      } else {
        _selectedImageString = returnedImage!.path;
      }
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        _selectedFile = File(returnedImage!.path);
      } else {
        _selectedImageString = returnedImage!.path;
      }
    });
  }
}
