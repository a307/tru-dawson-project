// picture_widget.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PictureWidget extends StatefulWidget {
  final String? controlName;
  const PictureWidget({
    super.key,
    required this.controlName,
  });
  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

String? selectedImageString;
File? selectedFile;
File? selectedFileChrome;
// String strUrl = "monkey";
List<Map<String, String>> strUrlList = [];
Future<String> photoUpload() async {
  String url = "";
  final ref =
      FirebaseStorage.instance.ref("images/" + DateTime.now().toString());
  if (!kIsWeb && selectedFile != null) {
    TaskSnapshot task = await ref.putFile(selectedFile!);
    await task;
    return await ref.getDownloadURL();
  } else if (kIsWeb && selectedFileChrome != null) {
    try {
      TaskSnapshot task =
          await ref.putData(await XFile(selectedImageString!).readAsBytes());
      return await task.ref.getDownloadURL();
    } catch (error) {
      print("Error uploading image: $error");
      return "";
    }
  } else {
    return "";
  }
}

class _PictureWidgetState extends State<PictureWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Picture", // Changed the name here to "Pictures" as it would display the appended identifier in repeatable sections
          textScaleFactor: 1.25,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            MaterialButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              color: Color(0xFF6F768A),
              textColor: Colors.white,
              child: const Text('Gallery'),
            ),
            SizedBox(
              width: 10,
              height: 10,
            ),
            MaterialButton(
                onPressed: () {
                  _pickImageFromCamera();
                },
                color: Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Camera')),
            SizedBox(width: 10, height: 10),
            //TODO clicking remove button removes photo from all upload fields
            MaterialButton(
                onPressed: () {
                  setState(() {
                    strUrlList.removeWhere(
                        (element) => element["name"] == widget.controlName);
                    // print(strUrlList);
                    // print(widget.controlName);
                    selectedImageString = null;
                    selectedFile = null;
                  });
                },
                color: Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Remove')),
          ],
        ),
        //if the slected image string (chrome) isnt null and platform is web, get image using Image.Network, otherwise display empty sizedbox
        selectedImageString != null && kIsWeb
            ? Image.network(
                selectedImageString!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        //if selected file (ios and android) isnt null and platform is android or ios, get image using Image.file, otherwise display empty sizedbox
        selectedFile != null && !kIsWeb
            ? Image.file(
                selectedFile!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : SizedBox(height: 0),
        SizedBox(width: 10, height: 10),
        MaterialButton(
            onPressed: () {
              photoUpload().then((String result) {
                setState(() {
                  // strUrl = result;
                  strUrlList.add({"name": widget.controlName!, "url": result});
                });
              });
            },
            color: Color(0xFF6F768A),
            textColor: Colors.white,
            child: const Text('Confirm Image')),
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
        if (!kIsWeb) {
          //get selected file when on ios or android
          selectedFile = File(returnedImage!.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          selectedFileChrome = File(returnedImage!.path);
          selectedImageString = returnedImage!.path;
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
        if (!kIsWeb) {
          //get selected file when on ios or android
          selectedFile = File(returnedImage!.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          selectedFileChrome = File(returnedImage!.path);
          selectedImageString = returnedImage!.path;
        }
      });
    }
  }
}
