import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:telephony/telephony.dart';

class TimerController extends GetxController {
  var seconds = 10.obs;
  final Telephony telephony = Telephony.instance;

  Timer? _timer;

  RxBool servicestatus = false.obs;
  RxBool haspermission = false.obs;
  late LocationPermission permission;
  late Position position;
  var long = "".obs;
  var lat = "".obs;
  var mapUrl="".obs;
  late StreamSubscription<Position> positionStream;
  late StreamSubscription<Position> _streamSubscription;

  RxBool dialogClose=false.obs;

  @override
  void onInit() {
    super.onInit();
    checkGps();
  }

  checkGps() async {
    bool serviceEnabled;


    LocationPermission permission;

    //Test if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission is denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission is permanently denied");
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    log(position.toString());

    _streamSubscription = Geolocator.getPositionStream().listen((Position position) {

      print("Longitude ${position.longitude}"); //Output: 80.24599079
      print("Latitude ${position.latitude}");
      mapUrl.value= "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      //getDeviceInfo();
      });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long.value = position.longitude.toString();
    lat.value = position.latitude.toString();

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long.value = position.longitude.toString();
      lat.value = position.latitude.toString();
    });
  }

  void startTimer(BuildContext context) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds.value--;
      if (seconds.value < 1) {
        seconds.value = 0;
        print("Time");
        sendSMS(context);
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    // seconds.value=0;
    _timer!.cancel();
    seconds.value = 10;
  }

  void sendSMS(context) async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    print(permissionsGranted);
    permissionsGranted == true
        ? telephony.sendSms(
            to: "123456",
            message: mapUrl.value,
            statusListener: (SendStatus val) {
              if (val.toString() == "SendStatus.SENT") {
                print("SENDING");
                showToast(message: "SMS SENDING....",backColor: Colors.green);
                dialogClose.value=true;
              } else if (val.toString() == "SendStatus.DELIVERED") {
                print("SUCCESS");
                showToast(message: "SMS SUCCESSFULLY SEND",backColor: Colors.green);
                dialogClose.value=true;
              } else {
                showToast(message: "SMS SENS FAILED",backColor: Colors.red);
                dialogClose.value=true;
                print("FAILED");
              }
            })
        : null;
  }


}


Future<bool?> showToast({message,backColor}) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backColor,
      textColor: Colors.white,
      fontSize: 16.0
  );
}