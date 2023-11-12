import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPastForms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205),
        title: Text('Past Submitted Forms'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getFormData('Sign Inspection'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Display a loading indicator while waiting for data.
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            Map<String, dynamic> data = (snapshot.data as Map<String, dynamic>);
            String content = '';
            data.forEach((key, value) => content += '$key: $value\n');
            return Text(content);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getFormData(String db) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(db).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if there is no data.
    }
  }
}
