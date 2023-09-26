import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('Users');

  Future updateUserData(String username, String password) async {
    return await collection
        .doc(uid)
        .set({'username': username, 'password': password});
  }
}
