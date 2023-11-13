import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_field.dart';
import 'generation.dart';
import 'package:intl/intl.dart'; // to turn the timestamp object back into a date
import 'package:tuple/tuple.dart'; //to make tuples, for ordering "Inspector Name 5734892754893 1" -> tuple
//this image package also has an instance of Color, which messes with everything. :/
//import 'package:image/image.dart'; // to load the images of previous forms from firebase to display
import 'picture_widget.dart';


class ViewPastForms extends StatefulWidget {
  final String globalEmail;

  ViewPastForms({required this.globalEmail});

  @override
  _ViewPastFormsState createState() => _ViewPastFormsState();
}

class _ViewPastFormsState extends State<ViewPastForms> {
  // pulling actual list of forms from from generation.dart
  final List<String> formTypes = globallist;
  // State variable to control form filtering
  bool showAllForms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(192, 2, 5, 1),
        title: Text('Past Submitted Forms'),
        actions: [
          // Toggle switch to show all forms or only user-submitted forms
          Switch(
            value: showAllForms,
            onChanged: (value) {
              setState(() {
                showAllForms = value;
              });
            },
          ),
        ],
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
            var filteredDocs = showAllForms
                ? allDocs
                : allDocs
                    .where((doc) => extractEmailFromFormId(doc.id) == widget.globalEmail)
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
        backgroundColor: Color.fromRGBO(192, 2, 5, 1),
        title: Text('Form Details - $formType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formType, style: TextStyle(fontSize: 20,color: Colors.black),),
              SizedBox(height: 8),
              Text('Date Submitted: ${extractDateFromFormId(formDocument.id) ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Submitted by: ${extractEmailFromFormId(formDocument.id) ?? 'N/A'}'),
              SizedBox(height: 16),
              Text('Form Data:', style: TextStyle(fontSize: 20,color: Colors.black)),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFormDataWidgets(formData),
              ),
            ],
          ),
        ),
      ),
    );
  }


List<Widget> _buildFormDataWidgets(Map<String, dynamic> formData) {
List<Tuple3<String, String, String>> formFields = [];
print(formData);
RegExp regex = RegExp(r'(.+?)\s(\d+)\s(.+)'); //to split all the name, long num, and short num
//for each data piece in the submitted form,
formData.forEach((key, value) {
  RegExpMatch? match = regex.firstMatch(key); //match the regex to get the pieces
  if (match != null) {
    
      String name = match.group(1) ?? '';
      //String longNumber = match.group(2) ?? '';   //we don't need this num as of now, maybe later? 
      String shortNumber = match.group(3) ?? '';
      if(value is Timestamp){ //change timestamp to usable date
          value = value.toDate();
          value = DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
        }
       else if (value is List<dynamic>) {
        // If a picture URL, fetch the pic from Firebase and display it.
        if (value.isNotEmpty) {
          value = value.first.toString();
        } else {
          value = 'No image'; // Handle the case where the list is empty
        }
      } else if (value == null) {
        value = 'Field left blank.';
      } 
      formFields.add(Tuple3(name, shortNumber, value));
  } else {
      // Handle cases where the regex doesn't match
      print('Unmatched key: $key');
    }
});

// Sort the form fields based on the short number
formFields.sort((a, b) {
  int shortNumberA = int.tryParse(a.item2) ?? 0;
  int shortNumberB = int.tryParse(b.item2) ?? 0;
  return shortNumberA.compareTo(shortNumberB);
});

// Generate widgets based on the sorted form fields
// return formFields.map((field) {
//   return Text('${field.item1}: ${field.item3}');
// }).toList();

// Create styled widgets
List<Widget> styledWidgets = formFields.map((field) {
  return Column(
  children: [
    Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(192, 2, 5, 1),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
            BoxShadow(
              color: Colors.grey, 
              offset: Offset(0, 2), 
              blurRadius: 4,
            ),
          ], 
          ),
          child: Text(
            '${field.item1}:',
            style: TextStyle(
              color: Colors.white, // Set the text color for item1
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(width: 8), // Add some spacing between the two parts
        Text(
          field.item3,
          style: TextStyle(
            color: Colors.black, // Set the text color for item3
            fontSize: 16,
          ),
        ),
      ],
    ),
    SizedBox(height: 8), // Add some vertical spacing as a spacer
  ],
);;
}).toList();

return styledWidgets;

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
