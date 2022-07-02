import 'dart:async';
import 'dart:convert';
import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/datamodels/driver.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/helpers/pushnotificationservice.dart';
import 'package:cargo_driver/widgets/ConfirmSheet.dart';
import 'package:cargo_driver/widgets/AvilabilityButton.dart';
import 'package:cargo_driver/widgets/ProgressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late GoogleMapController mapController;
  final Completer<GoogleMapController> _controller = Completer();

  String availabilityTitle = 'GO ONLINE';
  Color availabilityColor = BrandColors.colorOrange;
  late String phoneNum;
  late Query _ref;
  bool loading = true;
  late DatabaseReference tripRequestRef;
  Geolocator geolocator = Geolocator();

  void getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
  }

  void askLocationPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
  }

  void getCurrentDriverInfo() async {
    currentUser = FirebaseAuth.instance.currentUser!;

    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child("drivers/${currentUser.uid}");
    driverRef.once().then((value) {
      final dataSnapshot = value.snapshot;
      if (dataSnapshot != null) {
        currentDriverInfo = Driver.fromSnapShot(dataSnapshot);
      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.getToken(context);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref =  FirebaseDatabase.instance.ref("drivers").child(uid);
    ref.once().then((value) {
      var myData = json.decode(json.encode(value.snapshot.value));
      var phone = myData['phone'];
      phoneNum = phone;

      _ref =  FirebaseDatabase.instance
          .ref()
          .child('cargos')
          .orderByChild('driver_phone')
          .equalTo(phoneNum);
      setState(() {
        loading = false;
      });
    });


    getCurrentPosition();
    askLocationPermissions();
  }

  void showDilogue(jsonData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: AlertDialog(
            title: const Text('Details of Package'),
            content: Column(
              children: <Widget>[

                Row(
                  children: <Widget>[
                    const Text("Company:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(jsonData['company'].toString())
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("From Address:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['from_address'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("To Address:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['to_address'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("Total distance:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['total_distance'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("Total time:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData['total_time'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    const Text("User Phone:"),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        jsonData.containsKey("user_phone")
                            ? jsonData['user_phone']
                            : "No number",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCargoList({Object? data, String? key}) {
    final jsonData = json.decode(json.encode(data));
    if (jsonData['status']== 'ongoing' || jsonData['status'] == 'assigned') {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  const Text("Tracking ID:"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      key!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                      width: 80,
                      height: 20,
                      child: ElevatedButton(
                        onPressed: () => showDilogue(jsonData),
                        child: const Text("Details"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  const Text("status"),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      jsonData['status'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? ProgressDialog(status: "Loading..") : SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: FirebaseAnimatedList(
            query: _ref,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Object? data = snapshot.value;

              return _buildCargoList(data: data, key: snapshot.key);
            },
          ),
        ),
      ),
    );
  }

  void goOnline() {
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(
        currentUser.uid, currentPosition.latitude, currentPosition.longitude);
    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentUser.uid}/newtrip');
    tripRequestRef.set('waiting');
    tripRequestRef.onValue.listen((event) {});
  }

  void goOffline() {
    Geofire.removeLocation(currentUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
  }

  void getLocationUpdates() {
    homePositionStream =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if (isAvailable) {
        Geofire.setLocation(currentUser.uid, currentPosition.latitude,
            currentPosition.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
