import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/auth_service.dart';
import 'package:flutter_accelemotor_location/registration_page.dart';
import 'package:flutter_accelemotor_location/tect_field_widet.dart';
import 'package:flutter_accelemotor_location/timer_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          "LogIn",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  if(emailController.text.isEmpty&&passwordController.text.isEmpty){
                    showToast(message: "Insert your email & password", backColor: Colors.lightBlue);
                    return;
                  }

                  AuthService().signInWithGoogle(emailController.text, passwordController.text);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.green,
                child: const Text(
                  "Log In",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              sized15(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("  Don't have an account?  "),
                   GestureDetector(
                     onTap: (){
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const RegistrationPage()),
                       );
                     },
                     child: const Text(
                      "Registration",
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

SizedBox sized5() {
  return const SizedBox(height: 5);
}

SizedBox sized15() {
  return const SizedBox(height: 15);
}
