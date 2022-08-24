
import 'package:firebase_auth/firebase_auth.dart';

class Users{
  String? email;
  String? fullName;
  String? phoneNumber;

  Users({this.email,this.fullName,this.phoneNumber});

  Map<String,dynamic> toJson()=>{
    'email':email,
    'fullName':fullName,
    'phoneNumber':phoneNumber,
  };

  static Users fromJson(Map<String,dynamic>json)=>Users(
    email: json['email'],
    fullName: json['fullName'],
    phoneNumber: json['phoneNumber'],
  );

}