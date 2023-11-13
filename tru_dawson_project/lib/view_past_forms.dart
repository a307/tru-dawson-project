import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_field.dart';

class ViewPastForms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205),
        title: Text('Past Submitted Forms'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Sign Inspection').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No forms available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {

                var formDocument = snapshot.data!.docs[index];
                var formId = formDocument.id;
                var dateSubmitted = extractDateFromFormId(formId) ?? 'N/A';
                var email = extractEmailFromFormId(formId) ?? 'N/A';


                return ListTile(
                  title: Text('Sign Inspection'),
                  subtitle: Text('Date Submitted: $dateSubmitted\nSubmitted by: $email'),
                  onTap: () {
                    // Navigate to a new page to display detailed form data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormDetailsPage(formDocument),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  String? extractDateFromFormId(String formId) {
    // Extract the date from the form ID (assuming the format is "YYYYMMDD-email")
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(dashIndex + 1); // Extract the date before the first dash
    } catch (e) {
      return null;
    }
  }

  String? extractEmailFromFormId(String formId) {
    // Extract the email from the form ID (assuming the format is "YYYYMMDD-email")
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(0, dashIndex); // Extract the email after the first dash
    } catch (e) {
      return null;
    }
  }
}

class FormDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot formDocument;

  FormDetailsPage(this.formDocument);

  @override
  Widget build(BuildContext context) {
    var formData = formDocument.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205),
        title: Text('Form Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign Inspection'),
            SizedBox(height: 8),
            Text('Date Submitted: ${extractDateFromFormId(formDocument.id) ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Submitted by: ${extractEmailFromFormId(formDocument.id) ?? 'N/A'}'),
            SizedBox(height: 16),
            Text('Form Data:'),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildFormDataWidgets(formData),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormDataWidgets(Map<String, dynamic> formData) {
    List<Widget> widgets = [];
    formData.forEach((key, value) {
      widgets.add(FormFieldWidget(name: key, value: value));
    });
    return widgets;
  }

  String? extractDateFromFormId(String formId) {
    // Extract the date from the form ID (assuming the format is "YYYYMMDD-email")
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(dashIndex + 1); // Extract the date before the first dash
    } catch (e) {
      return null;
    }
  }

  String? extractEmailFromFormId(String formId) {
    // Extract the email from the form ID (assuming the format is "YYYYMMDD-email")
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(0, dashIndex); // Extract the email after the first dash
    } catch (e) {
      return null;
    }
  }
}
