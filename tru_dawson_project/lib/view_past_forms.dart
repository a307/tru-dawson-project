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
                var form = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                var dateSubmitted = form['dateSubmitted'] ?? 'N/A';

                return ListTile(
                  title: Text('Sign Inspection'),
                  subtitle: Text('Date Submitted: $dateSubmitted'),
                  onTap: () {
                    // Navigate to a new page to display detailed form data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormDetailsPage(form),
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
}

class FormDetailsPage extends StatelessWidget {
  final Map<String, dynamic> formData;

  FormDetailsPage(this.formData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign Inspection'),
            SizedBox(height: 8),
            Text('Date Submitted: ${formData['dateSubmitted'] ?? 'N/A'}'),
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
      widgets.add(Text('$key: $value'));
    });
    return widgets;
  }
}
