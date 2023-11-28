import 'package:crypt/crypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tru_dawson_project/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //create user object based on firebase user

  //If user is not null, return DawsonUser with Uid
  DawsonUser? _userFromFirebaseUser(User? user) {
    return user != null ? DawsonUser(uid: user.uid) : null;
  }

  //Call this to initiate a anonymous sign in (uid only)
  Future signInAnon() async {
    try {
      //Call signInAnonymously to actually complete the sign in
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      //Call function to get DawsonUser from FirebaseUser
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
    }
  }

  Future SignInEmailPass(String email, String password) async {
    try {
      //Call signInWithEmailAndPassword to actually complete the sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      User? user = result.user;
      //Call function to get DawsonUser from FirebaseUser
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
    }
  }

  Future SignUp(String email, String password) async {
    try {
      //Call createUserWithEmailAndPassword to actually complete the signup
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      User? user = result.user;
      //Call function to get DawsonUser from FirebaseUser
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
    }
  }

  Future SignInEmailPassOffline(
      String email, String password, String spEmail, String spPassword) async {
    try {
      //if email and password from form matches sharedpreferences return the email
      if (email == spEmail && Crypt(spPassword).match(password)) {
        return email;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
    }
  }

//disconnect user from firebase
  void SignOut() async {
    await _auth.signOut();
    print('Signed out of Firebase');
  }
}
