import 'dart:async';

import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/widgets/ConfirmSheet.dart';
import 'package:cargo_driver/widgets/TaxiButton.dart';
import 'package:cargo_driver/widgets/AvilabilityButton.dart';
import 'package:firebase_database/firebase_database.dart';
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

  bool isAvailable = false;

  late Position currentPosition;
  late DatabaseReference tripRequestRef;
  Geolocator geolocator = Geolocator();

  void getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));
  }

  void askLocationPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: const EdgeInsets.only(top: 135),
          initialCameraPosition: googlePlex,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;
            getCurrentPosition();
            askLocationPermissions();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),
        Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AvilabilityButton(
                  color: availabilityColor,
                  title: availabilityTitle,
                  onPressed: () {
                    showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (BuildContext context) => ConfirmSheet(
                              title:
                                  (!isAvailable) ? "GO ONLINE" : "GO OFFLINE",
                              subtitle: (!isAvailable)
                                  ? "You are now available to receive trip requests"
                                  : "You will stop receiving new trip requests",
                              onPressed: () {
                                if (!isAvailable) {
                                  goOnline();
                                  getLocationUpdates();
                                  Navigator.pop(context);
                                  setState(() {
                                    availabilityColor = BrandColors.colorGreen;
                                    availabilityTitle = 'GO OFFLINE';
                                    isAvailable = true;
                                  });
                                } else {
                                  goOffline();
                                  Navigator.pop(context);
                                  setState(() {
                                    availabilityColor = BrandColors.colorOrange;
                                    availabilityTitle = 'GO ONLINE';
                                    isAvailable = false;
                                  });
                                }
                              },
                            ));
                  },
                )
              ],
            ))
      ],
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
      if(isAvailable){
        Geofire.setLocation(
            currentUser.uid, currentPosition.latitude, currentPosition.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
