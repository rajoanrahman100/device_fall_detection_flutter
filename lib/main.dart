import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/auth_service.dart';
import 'package:flutter_accelemotor_location/sensor_test_screen.dart';
import 'package:flutter_accelemotor_location/test_screen.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

import 'newmorphic_flutter.dart';
import 'timer_controller.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  // Tha main function which call first
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: AuthService().handleAuthState(), //Check the authentication state of the user
    );
  }
}


class MyAppTwo extends StatefulWidget {
  const MyAppTwo({Key? key}) : super(key: key);

  @override
  State<MyAppTwo> createState() => _MyAppState();
}

class _MyAppState extends State<MyAppTwo> {
  String text = "Stop Service";

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

  var timerC = Get.put(TimerController());

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

    timerC.startTimer(context);

    /*showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        timerC.startTimer(context);
        return Dialog(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: () {
                          timerC.stopTimer();
                          startTime = null;
                          endTime = null;
                          print(accelValuesForAnalysis.toString());
                          accelValuesForAnalysis.clear();
                          setState(() {
                            isBeingThrown = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.black,
                          size: 30,
                        )),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "It seems your device has fallen.Are you okay?",
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Obx(
                        () => Container(
                        height: 35,
                        width: 35,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black)),
                        child: Center(
                            child: Text(
                              "${timerC.seconds.value}",
                              style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                            ))),
                  ),
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
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  isBeingThrown = true;
                  startTime = DateTime.now();
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}