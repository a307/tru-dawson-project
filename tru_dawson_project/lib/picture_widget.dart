// picture_widget.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ignore: must_be_immutable
class PictureWidget extends StatefulWidget {
  final String? controlName;
  String? selectedImageString;
  File? selectedFile;
  File? selectedFileChrome;
  PictureWidget({
    Key? key,
    required this.controlName,
    this.selectedImageString,
    this.selectedFile,
    this.selectedFileChrome,
  }) : super(key: key);

  @override
  State<PictureWidget> createState() => _PictureWidgetState();
}

// String? selectedImageString;
// File? selectedFile;
// File? selectedFileChrome;
//URL list, associated with fieldname
List<Map<String, String>> strUrlList = [];

class _PictureWidgetState extends State<PictureWidget>
    with AutomaticKeepAliveClientMixin {
  Future<String> photoUpload() async {
    String url = "";
    //get instance of firebase storage in images with todays date and time as the name of the image file
    final ref = FirebaseStorage.instance.ref("images/${DateTime.now()}");
    //if on IOS or Android and there is a selected file
    if (!kIsWeb && widget.selectedFile != null) {
      //add file to firebase storage
      TaskSnapshot task = await ref.putFile(widget.selectedFile!);
      task;
      //wait for URL to come back from storage
      return await ref.getDownloadURL();
    }
    //if on web and theres a selected file
    else if (kIsWeb && widget.selectedFileChrome != null) {
      try {
        //upload image as bytes
        TaskSnapshot task = await ref
            .putData(await XFile(widget.selectedImageString!).readAsBytes());
        //wait for URL to come back from storage
        return await task.ref.getDownloadURL();
      } catch (error) {
        print("Error uploading image: $error");
        return "";
      }
    } else {
      return "";
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Picture", // Changed the name here to "Pictures" as it would display the appended identifier in repeatable sections
          textScaleFactor: 1.25,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            MaterialButton(
              onPressed: () async {
                await _pickImageFromGallery();
              },
              color: const Color(0xFF6F768A),
              textColor: Colors.white,
              child: const Text('Gallery'),
            ),
            const SizedBox(
              width: 10,
              height: 10,
            ),
            MaterialButton(
                onPressed: () async {
                  _pickImageFromCamera();
                },
                color: const Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Camera')),
            const SizedBox(width: 10, height: 10),
            MaterialButton(
                //if remove image button is pressed, remove URL from submission form and null out selected image data
                onPressed: () {
                  setState(() {
                    strUrlList.removeWhere(
                        (element) => element["name"] == widget.controlName);
                    // print(strUrlList);
                    // print(widget.controlName);
                    widget.selectedImageString = null;
                    widget.selectedFile = null;
                  });
                },
                color: const Color(0xFF6F768A),
                textColor: Colors.white,
                child: const Text('Remove')),
          ],
        ),
        //if the slected image string (chrome) isnt null and platform is web, get image using Image.Network, otherwise display empty sizedbox
        widget.selectedImageString != null && kIsWeb
            ? Image.network(
                widget.selectedImageString!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : const SizedBox(height: 0),
        //if selected file (ios and android) isnt null and platform is android or ios, get image using Image.file, otherwise display empty sizedbox
        widget.selectedFile != null && !kIsWeb
            ? Image.file(
                widget.selectedFile!,
                fit: BoxFit.contain,
                //Make photo only 100x100
                width: 100.0,
                height: 100.0,
              )
            : const SizedBox(height: 0),
        const SizedBox(width: 10, height: 10),
        MaterialButton(
            //when confirm image is clicked, add URL and control name to the URL list above
            onPressed: () {
              photoUpload().then((String result) {
                setState(() {
                  // strUrl = result;
                  strUrlList.add({"name": widget.controlName!, "url": result});
                });
              });
            },
            color: const Color(0xFF6F768A),
            textColor: Colors.white,
            child: const Text('Confirm Image')),
        const SizedBox(height: 20)
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
          widget.selectedFile = File(returnedImage.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          widget.selectedFileChrome = File(returnedImage.path);
          widget.selectedImageString = returnedImage.path;
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
          widget.selectedFile = File(returnedImage.path);
        } else if (kIsWeb) {
          //just get the path when on chrome
          widget.selectedFileChrome = File(returnedImage.path);
          widget.selectedImageString = returnedImage.path;
        }
      });
    }
  }
}
