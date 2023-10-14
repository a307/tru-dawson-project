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
          textScaleFactor: 1.25,
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
            SizedBox(width: 10),
            MaterialButton(
                onPressed: () {
                  setState(() {
                    _selectedImageString = null;
                    _selectedFile = null;
                  });
                },
                color: Colors.blue,
                child: const Text('Remove Image')),
          ],
        ),
        //if the slected image string (chrome) isnt null and platform is web, get image using Image.Network, otherwise display empty sizedbox
        _selectedImageString != null && kIsWeb
            ? Image.network(
                _selectedImageString!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        //if selected file (ios and android) isnt null and platform is android or ios, get image using Image.file, otherwise display empty sizedbox
        _selectedFile != null &&
                    defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS
            ? Image.file(
                _selectedFile!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        SizedBox(height: 20)
      ],
    );
  }

  Future _pickImageFromGallery() async {
    //get image from gallery or file system
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    //make sure return image isnt null or else if we dont select a photo it will just crash
    if (returnedImage != null) {
      setState(() {
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          //get selected file when on ios or android
          _selectedFile = File(returnedImage!.path);
        } else {
          //just get the path when on chrome
          _selectedImageString = returnedImage!.path;
        }
      });
    }
  }

  Future _pickImageFromCamera() async {
    //get image from camera (on chrome it just opens another filesystem)
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    //make sure return image isnt null or else if we dont select a photo it will just crash
    if (returnedImage != null) {
      setState(() {
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          //get selected file when on ios or android
          _selectedFile = File(returnedImage!.path);
        } else {
          //just get the path when on chrome
          _selectedImageString = returnedImage!.path;
        }
      });
    }
  }
}
