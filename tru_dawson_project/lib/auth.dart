import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
}
