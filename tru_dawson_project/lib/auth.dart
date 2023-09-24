import 'package:firebase_auth/firebase_auth.dart';
import 'package:tru_dawson_project/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user object based on firebase user

  DawsonUser? _userFromFirebaseUser(User? user) {
    return user != null ? DawsonUser(uid: user.uid) : null;
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
    }
  }
}
