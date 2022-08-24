import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/tect_field_widet.dart';
import 'package:flutter_accelemotor_location/timer_controller.dart';

import 'auth_service.dart';
import 'log_in_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var namedController = TextEditingController();

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        title: const Text(
          "Registration",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name"),
              sized5(),
              TextFieldWidget(
                textEditingController: namedController,
              ),
              const Text("Email"),
              sized5(),
              TextFieldWidget(
                textEditingController: emailController,
              ),
              sized15(),
              const Text("Password"),
              sized5(),
              TextFieldWidget(
                textEditingController: passwordController,
                isObsecure: true,
              ),
              sized15(),
              sized15(),
              MaterialButton(
                height: 45,
                minWidth: double.infinity,
                onPressed: () {
                  if (emailController.text.isEmpty && passwordController.text.isEmpty && namedController.text.isEmpty) {
                    showToast(message: "Fill up all the fields", backColor: Colors.lightBlue);
                    return;
                  }
                  AuthService().signUpWithGoogle(namedController.text,emailController.text, passwordController.text,context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.green,
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              sized15(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("  Already have an account?  "),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
