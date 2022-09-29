import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/activity_model.dart';
import 'package:flutter_accelemotor_location/user_model.dart';
import 'package:flutter_accelemotor_location/utils.dart';

import 'log_in_page.dart';

class ProfilePage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar( //App Bar Portion
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
        future: readUser(), //Method to get profile data
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
                        Expanded(child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Name",
                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                  Text(
                                    "${user.fullName}",
                                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Email",
                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                  Text(
                                    "${user.email}",
                                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Added Number",
                                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                  Text(
                                    "${user.phoneNumber}",
                                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Activity Log",
                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                //This is the query we perform for fetching activity log from "activity" collection.We have filtered via our unique UID
                                stream: FirebaseFirestore.instance.collection("activity").where('uid',isEqualTo: boxStorage.read(UID)).snapshots(),
                                builder: (context,snapshot){
                                  if(snapshot.connectionState==ConnectionState.waiting){
                                    return Container();
                                  }
                                  else if(snapshot.connectionState==ConnectionState.active){
                                    if(snapshot.data!.docs.isNotEmpty){
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (_,index){
                                          return Column(
                                            children: [
                                              ListTile(
                                                title:Text("Falling Time ${snapshot.data!.docs[index]["fall_time"]}"),
                                                subtitle:Text("Falling Date ${snapshot.data!.docs[index]["fall_date"]}"),
                                              ),
                                              Divider()
                                            ],
                                          );
                                        },
                                      );
                                    }else{
                                      return Container(padding: EdgeInsets.symmetric(vertical: 40.0),child: const Center(child: Text("No activity is recorded yet"),),);
                                    }
                                  }else{
                                    return Container();
                                  }

                                },
                              ),


                            ],
                          ),
                        )),
                        MaterialButton(
                          height: 45,
                          minWidth: double.infinity,
                          onPressed: () async {
                            //Signing out from the app and user will land on Login page
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



  //Function from where we are fetching data and show it this page
  Future<Users?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(boxStorage.read(UID)); //"user" our collection name
    final snapShot = await docUser.get();

    if (snapShot.exists) {
      return Users.fromJson(snapShot.data()!);
    }
  }


}
