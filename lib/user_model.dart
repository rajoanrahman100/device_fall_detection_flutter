
import 'package:firebase_auth/firebase_auth.dart';

class Users{
  String? email;
  String? fullName;
  String? phoneNumber;
  String? uid;

  Users({this.email,this.fullName,this.phoneNumber,this.uid});

  Map<String,dynamic> toJson()=>{
    'email':email,
    'fullName':fullName,
    'phoneNumber':phoneNumber,
    'uid':uid,
  };

  static Users fromJson(Map<String,dynamic>json)=>Users(
    email: json['email'],
    fullName: json['fullName'],
    phoneNumber: json['phoneNumber'],
    uid: json['uid'],
  );

}