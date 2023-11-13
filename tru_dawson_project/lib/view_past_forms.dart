import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_field.dart';

class ViewPastForms extends StatelessWidget {
  final String globalEmail;

  ViewPastForms({required this.globalEmail});

  // List of form types (replace these with your actual collection names)
  final List<String> formTypes = ['Sign Inspection', 'Fuel Usage', 'Truck Inspection', 'Equipment Inspection'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205),
        title: Text('Past Submitted Forms'),
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        // Fetch data for all form types concurrently
        future: Future.wait(
          formTypes.map((formType) =>
              FirebaseFirestore.instance.collection(formType).get()),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Combine all form documents into a single list
            var allDocs = snapshot.data!.expand((docs) => docs.docs).toList();

            // Filter the documents based on the globalEmail
            var filteredDocs = allDocs
                .where((doc) => extractEmailFromFormId(doc.id) == globalEmail)
                .toList();

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                var formDocument = filteredDocs[index];
                var formId = formDocument.id;
                var dateSubmitted = extractDateFromFormId(formId) ?? 'N/A';
                var email = extractEmailFromFormId(formId) ?? 'N/A';

                return ListTile(
                  title: Text('Form Type: ${getFormType(formDocument)}'),
                  subtitle: Text('Date Submitted: $dateSubmitted\nSubmitted by: $email'),
                  onTap: () {
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
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(dashIndex + 1);
    } catch (e) {
      return null;
    }
  }

  String? extractEmailFromFormId(String formId) {
    try {
      var dashIndex = formId.indexOf('-');
      return formId.substring(0, dashIndex);
    } catch (e) {
      return null;
    }
  }

  String getFormType(QueryDocumentSnapshot formDocument) {
    // Extract form type from the document (you may need to adjust this based on your data structure)
    // Assuming the form type is encoded in the collection name
    return formDocument.reference.parent?.id ?? 'Unknown';
  }
}


class FormDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot formDocument;

  FormDetailsPage(this.formDocument);

  @override
  Widget build(BuildContext context) {
    var formData = formDocument.data() as Map<String, dynamic>;
    var formType = getFormType(formDocument);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC00205),
        title: Text('Form Details - $formType'), // Use the dynamic form type here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formType), // Use the dynamic form type here
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

  String getFormType(QueryDocumentSnapshot formDocument) {
    // Extract form type from the document (you may need to adjust this based on your data structure)
    // Assuming the form type is encoded in the collection name
    return formDocument.reference.parent?.id ?? 'Unknown';
  }
}
