import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference conditionalCollection =
      FirebaseFirestore.instance.collection('Conditional');
  Future updateUserData(String username, String password) async {
    return await collection
        .doc(uid)
        .set({'username': username, 'password': password});
  }

  Future updateConditionalFormData(String option, String textfield) async {
    return await conditionalCollection
        .doc()
        .set({'option': option, 'textfield': textfield});
  }
}
