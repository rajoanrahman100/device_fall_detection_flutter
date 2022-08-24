import 'dart:async';
import 'dart:math';
import 'package:flutter_accelemotor_location/timer_controller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class NeumorphicFlutter extends StatefulWidget {
  const NeumorphicFlutter({Key? key}) : super(key: key);

  @override
  _NeumorphicFlutterState createState() => _NeumorphicFlutterState();
}

class _NeumorphicFlutterState extends State<NeumorphicFlutter> with WidgetsBindingObserver{

  _getPermission() async => await [
    Permission.sms,
  ].request();

  Future<bool> _isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  _sendMessage(String phoneNumber, String message, {int? simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
    }
  }

  double x = 0, y = 0, z = 0;
  String direction = "none";

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  DateTime? startTime;
  DateTime? endTime;
  bool isBeingThrown = false;
  final double GRAVITATIONAL_FORCE = 9.80665;
  final double DECELERATION_THRESHOLD = 2; // <---- experimental
  List<double> accelValuesForAnalysis = <double>[];

  var seconds = 10;

  var timerC = Get.put(TimerController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addObserver(this);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance!.removeObserver(this);

    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);


    final isBackGround=state==AppLifecycleState.paused;


    if(isBackGround){
      print("App is Background");
      _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
        if (isBeingThrown) {
          // print("CALL EVENT");
          double x_total = pow(event.x, 2).toDouble();
          double y_total = pow(event.y, 2).toDouble();
          double z_total = pow(event.z, 2).toDouble();

          double totalXYZAcceleration = sqrt(x_total + y_total + z_total);

          // only needed because we are not using UserAccelerometerEvent
          // (because it was acting weird on my test phone Galaxy S5)
          double accelMinusGravity = totalXYZAcceleration - GRAVITATIONAL_FORCE;

          accelValuesForAnalysis.add(accelMinusGravity);
          print("Calculation ${accelMinusGravity.toString()}");

          if (accelMinusGravity > DECELERATION_THRESHOLD) {
            isBeingThrown = false;
            endTime = DateTime.now();
            Duration totalTime = DateTime.now().difference(startTime!);
            double totalTimeInSeconds = totalTime.inMilliseconds / 1000;
            double heightInMeters = (GRAVITATIONAL_FORCE * pow(totalTimeInSeconds, 2)) / 8;

           print("Calculationssssssssss ${accelValuesForAnalysis.toString()}");
          }
        }
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () async {
          setState(() {

          });
          isBeingThrown = true;
          startTime = DateTime.now();
          if (await _isPermissionGranted()) {
            _sendMessage("09xxxxxxxxx", "Hello");
          } else
            _getPermission();
        },

      ),
    );
  }
}
