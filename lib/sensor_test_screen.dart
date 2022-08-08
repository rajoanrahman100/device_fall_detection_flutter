import 'dart:async';
import 'dart:math';
import 'package:telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/timer_controller.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorTestScreen extends StatefulWidget {
  const SensorTestScreen({Key? key}) : super(key: key);

  @override
  _SensorTestScreenState createState() => _SensorTestScreenState();
}

class _SensorTestScreenState extends State<SensorTestScreen> {
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
  final double DECELERATION_THRESHOLD = 10; // <---- experimental
  List<double> accelValuesForAnalysis = <double>[];

  var seconds = 10;

  var timerC=Get.put(TimerController());



  @override
  void initState() {
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      if (isBeingThrown) {
        double x_total = pow(event.x, 2).toDouble();
        double y_total = pow(event.y, 2).toDouble();
        double z_total = pow(event.z, 2).toDouble();

        double totalXYZAcceleration = sqrt(x_total + y_total + z_total);

        // only needed because we are not using UserAccelerometerEvent
        // (because it was acting weird on my test phone Galaxy S5)
        double accelMinusGravity = totalXYZAcceleration - GRAVITATIONAL_FORCE;

        accelValuesForAnalysis.add(accelMinusGravity);
        if (accelMinusGravity > DECELERATION_THRESHOLD) {
          _throwHasEnded();
        }
      }
    }));

    super.initState();
  }

  void _throwHasEnded() {
    isBeingThrown = false;
    endTime = DateTime.now();
    Duration totalTime = DateTime.now().difference(startTime!);
    double totalTimeInSeconds = totalTime.inMilliseconds / 1000;
    double heightInMeters = (GRAVITATIONAL_FORCE * pow(totalTimeInSeconds, 2)) / 8;


    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        timerC.startTimer();
        return Dialog(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "It seems your device has fallen.Are you okay?",
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Obx(()=>Container(height: 35,width: 35,padding: const EdgeInsets.all(5.0),decoration: BoxDecoration(
                    shape: BoxShape.circle,border: Border.all(color: Colors.black)
                  ),child: Center(child: Text("${timerC.seconds.value}",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),))),),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () {
                      timerC.stopTimer();
                      startTime = null;
                      endTime = null;
                      print(accelValuesForAnalysis.toString());
                      accelValuesForAnalysis.clear();
                      Navigator.pop(context);
                      setState(() {
                        isBeingThrown = false;
                      });
                    },
                    child: const Text(
                      "YES",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    splashColor: Colors.grey,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // cancel the stream from the accelerometer somehow!! ugh!!!
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  bool _isElevated = true;


  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    return Scaffold(
        body: SizedBox.expand(
            child: Container(
      color: Colors.grey[300],
      child: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {

              // _throwHasEnded();
              //timerC.startTimer();
              isBeingThrown = true;
              startTime = DateTime.now();
            });
          },
          child: (!isBeingThrown)
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 200,
                  width: 200,
                  child: const Center(
                      child: Text(
                    "GO",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  )),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(50), boxShadow: [
                    BoxShadow(color: Colors.grey[500]!, offset: const Offset(4, 4), blurRadius: 15, spreadRadius: 1),
                    const BoxShadow(color: Colors.green, offset: Offset(-4, -4), blurRadius: 15, spreadRadius: 1)
                  ]),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 200,
                  width: 200,
                  child: const Center(
                      child: Text(
                    "Sensor Starts Working",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(50), boxShadow: [
                    BoxShadow(color: Colors.grey[500]!, offset: const Offset(4, 4), blurRadius: 15, spreadRadius: 1),
                    BoxShadow(color: Colors.red, offset: Offset(-2, -2), blurRadius: 15, spreadRadius: 2)
                  ]),
                ),
        ),
      ),
      //alignment: Alignment.center,
    )));
  }
}



/*Widget resetButton = TextButton(
      child: const Text("I'm okay"),
      onPressed: () {
        // startTime = null;
        // endTime = null;
        // print(accelValuesForAnalysis.toString());
        // accelValuesForAnalysis.clear();
        // Navigator.pop(context);
        // setState(() {
        //   isBeingThrown = false;
        // });
      },
      onLongPress: () {},
    );

    AlertDialog alert = AlertDialog(
      title: const Text(
        "Alert",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      content: Text("Are you okay?"),
      */ /*content: Text("total throw time in seconds was: " +
          totalTimeInSeconds.toString() +
          "\n" +
          "Total height was: " +
          heightInMeters.toString() +
          " meters. \n"),*/ /*
      actions: [
        resetButton,
      ],*/
// );