import 'dart:async';
import 'dart:developer';

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

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds.value--;
      if (seconds.value < 1) {
        seconds.value = 0;
        print("Time");
        sendSMS();
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    // seconds.value=0;
    _timer!.cancel();
    seconds.value = 10;
  }

  void sendSMS() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    print(permissionsGranted);
    permissionsGranted == true
        ? telephony.sendSms(
            to: "01788810008",
            message: mapUrl.value,
            statusListener: (SendStatus val) {
              //print("statua $val");
              if (val.toString() == "SendStatus.SENT") {
                print("SENDING");
              } else if (val.toString() == "SendStatus.DELIVERED") {
                print("SUCCESS");
              } else {
                print("FAILED");
              }
            })
        : null;
  }
}
