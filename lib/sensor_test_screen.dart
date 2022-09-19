import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accelemotor_location/profile_page.dart';
import 'package:flutter_accelemotor_location/timer_controller.dart';
import 'package:flutter_accelemotor_location/user_model.dart';
import 'package:flutter_accelemotor_location/utils.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'log_in_page.dart';
import 'notifications/localnotification_service.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


class SensorTestScreen extends StatefulWidget {
  var payLoad;


  SensorTestScreen({this.payLoad});

  @override
  _SensorTestScreenState createState() => _SensorTestScreenState();
}

class _SensorTestScreenState extends State<SensorTestScreen> with WidgetsBindingObserver {
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
  final double DECELERATION_THRESHOLD = 7; // <---- experimental
  List<double> accelValuesForAnalysis = <double>[];

  var seconds = 10;

  var timerC = Get.put(TimerController());

  String? userName;
  String? uid;

  int smsCount = 0;

  Timer? timer;

  //Notification Service
  late final LocalNotificationService service;

  void stopTimer() {
    timer?.cancel();
  }

  Future<Users?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(boxStorage.read(UID));
    final snapShot = await docUser.get();

    if (snapShot.exists) {
      return Users.fromJson(snapShot.data()!);
    }
  }

  Future getUserName() async {
    final docUser = FirebaseFirestore.instance.collection("users").doc(boxStorage.read(UID));
    final snapShot = await docUser.get();

    if (snapShot.exists) {
      Users data = Users.fromJson(snapShot.data()!);
      userName = data.fullName;
      uid = data.uid;
      print("User Full name $userName");
    }
  }

  callBack() {
    print("-------------------CALLING-----------------------");
  }

  stopCallBack() {
    print("-------------------STOP CALLING-----------------------");
  }

  Future<void> addActivity(uid) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection('activity');

    return users
        .add({
          'fall_date': DateFormat.yMd().format(DateTime.now()).toString(), // John Doe
          'fall_time': DateFormat.Hm().format(DateTime.now()).toString(), // Stokes and Sons
          'uid': uid // 42
        })
        .then((value) => print("------------------------Activity Added-----------------"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  void initState() {

    print("Payload ${widget.payLoad}");

   // widget.payLoad=="payload navigation"?isBeingThrown=false:null;

    WidgetsBinding.instance!.addObserver(this);

    service = LocalNotificationService();
    listenNotification();
    service.intialize();

    print("Todays date ${DateFormat.yMd().format(DateTime.now())}");
    print("Current time ${DateFormat.Hm().format(DateTime.now())}");

    getUserName();

    super.initState();
  }

  _sendMessage(String phoneNumber, String message, {int? simSlot}) async {
    print(phoneNumber);
    var result = await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      print("Sent");
    } else {
      print("Failed");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    final isBackGround = state == AppLifecycleState.paused;

    if (isBackGround) {
      print("App is Background");
      _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) async {
        if (isBeingThrown) {
          // print("CALL EVENT");
          double x_total = pow(event.x, 2).toDouble();
          double y_total = pow(event.y, 2).toDouble();
          double z_total = pow(event.z, 2).toDouble();

          double totalXYZAcceleration = sqrt(x_total + y_total + z_total);
          double accelMinusGravity = totalXYZAcceleration - GRAVITATIONAL_FORCE;

          accelValuesForAnalysis.add(accelMinusGravity);
          print("Accel Minus Gravity ${accelMinusGravity.toString()}");

          if (accelMinusGravity > DECELERATION_THRESHOLD) {
            print("Calculationssssssssss ${accelValuesForAnalysis.toString()}");



            await service.showPayloadNotification(id: 0, title: "A device fall is detected", body: "'Tap' if you are okay",payload: "payload navigation");

             /*timer = Timer(Duration(seconds: 5), () {
              print("CALLING");
            });*/

            timer=Timer(Duration(seconds: 10), () async {
              print('delayed execution after 10');
              smsCount = smsCount + 1;
              if (await _isPermissionGranted()) {
                smsCount > 3
                    ? stopCallBack()
                    : _sendMessage("${boxStorage.read(SAVED_NUMBER)}", "$userName is in danger.\nPlease help him.\nHis/Her location\n${timerC.mapUrl.value}");
              }
            });



            addActivity(uid);

            // isBeingThrown = false;
            endTime = DateTime.now();
            Duration totalTime = DateTime.now().difference(startTime!);
            double totalTimeInSeconds = totalTime.inMilliseconds / 1000;
            double heightInMeters = (GRAVITATIONAL_FORCE * pow(totalTimeInSeconds, 2)) / 8;

          }
        }else{
          for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
            subscription.cancel();
          }
        }
      }));
    }else{

    }
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
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    // cancel the stream from the accelerometer somehow!! ugh!!!
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  bool _isElevated = true;

  _getPermission() async => await [
        Permission.sms,
      ].request();

  Future<bool> _isPermissionGranted() async => await Permission.sms.status.isGranted;

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();

    print("UID ${boxStorage.read(UID)}");


    // widget.payLoad=="payload navigation"?isBeingThrown=false:null;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          actions: [
            IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ProfilePage()),
                  );
                  //await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 28,
                )),
            Container(
              width: 5.0,
            ),
          ],
        ),
        body: SizedBox.expand(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // _throwHasEnded();
                      //timerC.startTimer();
                      isBeingThrown = true;
                      startTime = DateTime.now();

                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
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
                                            Navigator.of(context).pop();
                                          },
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Colors.black,
                                            size: 30,
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 30.0,
                                    ),
                                    Text(
                                      "The sensor will run in the background.You can minimize your app.",
                                      style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _getPermission();
                                      },
                                      child: const Text(
                                        "OKAY",
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
                      : GestureDetector(
                          onTap: () {
                            isBeingThrown = false;
                            smsCount = 0;
                            timer!.cancel();
                            setState(() {});
                          },
                          child: AnimatedContainer(
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
              ),
              //alignment: Alignment.center,
            ),
            sized15(),
            sized15(),
            const Text("sms will send to this number"),
            sized15(),
            FutureBuilder<Users?>(
              future: readUser(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data;
                  boxStorage.write(SAVED_NUMBER, user?.phoneNumber);
                  return user == null
                      ? const Center(
                          child: Text("No number found"),
                        )
                      : Text(
                          "${user.phoneNumber}",
                          style: TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        )));
  }

  void listenNotification() => service.onNotificationClick.stream.listen(onNotificationListener);

  void onNotificationListener(String? payload) async{
    if(payload!=null&&payload.isNotEmpty){
      print('payload $payload');

      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: 'com.example.flutter_accelemotor_location', // replace com.example.app with your applicationId
        );
        await intent.launch();
      }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SensorTestScreen(payLoad: payload ,)),
      // );
    }
  }
}
