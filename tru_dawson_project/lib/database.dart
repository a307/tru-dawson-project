import 'package:cloud_firestore/cloud_firestore.dart';

//TESTING, HOW TO USE FIRESTORE DATABASE
class DatabaseService {
  final String uid;
  //Constructor to create DatabaseService instance with Uid as its only field
  DatabaseService({required this.uid});
  //Collection reference to the Users collection in Firestore database
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Users');
  //Collections reference to the Conditional collection in Firestore database
  final CollectionReference conditionalCollection =
      FirebaseFirestore.instance.collection('Conditional');

  //Send data to database with collection name: Users
  Future updateUserData(String username, String password) async {
    return await collection
        .doc(uid)
        .set({'username': username, 'password': password});
  }

  //Send data to database with collection name: Conditional
  Future updateConditionalFormData(String option, String textfield) async {
    return await conditionalCollection
        .doc()
        .set({'option': option, 'textfield': textfield});
  }
}
