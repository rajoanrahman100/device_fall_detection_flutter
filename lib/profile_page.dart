import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/user_model.dart';
import 'package:flutter_accelemotor_location/utils.dart';

import 'log_in_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [],
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<Users?>(
        future: readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            return user == null
                ? const Center(
                    child: Text("No User"),
                  )
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Name",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                            Text(
                              "${user.fullName}",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                            Text(
                              "${user.email}",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Added Number",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                            Text(
                              "${user.phoneNumber}",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                          ],
                        ),
                        sized15(),
                        sized15(),
                        sized15(),
                        MaterialButton(
                          height: 45,
                          minWidth: double.infinity,
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.green,
                          child: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<Users?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(boxStorage.read(UID));
    final snapShot = await docUser.get();

    if (snapShot.exists) {
      return Users.fromJson(snapShot.data()!);
    }
  }
}
