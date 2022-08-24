import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/sensor_test_screen.dart';
import 'package:flutter_accelemotor_location/timer_controller.dart';
import 'package:flutter_accelemotor_location/utils.dart';

import 'log_in_page.dart';

class AuthService {
  //1. handle auth state

  //2. Sign in with google

  //3. Sign Out



  Future<void> addUser(name, email, uid,number) {
    // Call the user's CollectionReference to add a new user
    DocumentReference users = FirebaseFirestore.instance.collection('users').doc(uid);

    return users
        .set({
          'fullName': name, // John Doe
          'email': email, // Stokes and Sons
          'phoneNumber': number, // Stokes and Sons
          'uid': uid // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  handleAuthState() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return const SensorTestScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  signUpWithGoogle(name,email, pass, context,number,TimerController timerC) async {


    timerC.showRegInLoad.value=true;

    try {
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );


      addUser(name,email,credential.user?.uid,number);
      boxStorage.write(UID, credential.user?.uid);
      //log("Userssss$credential");
      showToast(message: 'Registration Successful', backColor: Colors.green);
      timerC.showRegInLoad.value=false;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SensorTestScreen()),
      );
    } on FirebaseAuthException catch (e) {
      timerC.showRegInLoad.value=false;
      if (e.code == 'email-already-in-use') {
        showToast(message: 'Email already in use.', backColor: Colors.red);
        return;
      } else if (e.code == 'invalid-email') {
        showToast(message: 'Email is invalid.', backColor: Colors.red);
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  signInWithGoogle(email, pass,TimerController timerC,context) async {

    timerC.showSignInLoad.value=true;


    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      timerC.showSignInLoad.value=false;
      showToast(message: 'Login Successful', backColor: Colors.green);
      boxStorage.write(UID, credential.user?.uid);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SensorTestScreen()),
      );
      log(" $credential");
    } on FirebaseAuthException catch (e) {
      timerC.showSignInLoad.value=false;
      if (e.code == 'user-not-found') {
        showToast(message: 'No user found for that email.', backColor: Colors.red);
        return;
      } else if (e.code == 'wrong-password') {
        showToast(message: 'Wrong password provided for that user.', backColor: Colors.red);
        return;
      } else if (e.code == 'invalid-email') {
        showToast(message: 'Email is invalid.', backColor: Colors.red);
        return;
      }
    } catch (e) {
      print(e);
    }
  }
}

//Sign out
signOut() {
  FirebaseAuth.instance.signOut();
}
