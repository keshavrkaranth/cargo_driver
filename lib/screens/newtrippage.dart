import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_location/background_location.dart';
import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/datamodels/tripdetails.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/helpers/helpermethods.dart';
import 'package:cargo_driver/helpers/mapkithelper.dart';
import 'package:cargo_driver/widgets/ProgressDialog.dart';
import 'package:cargo_driver/widgets/TaxiButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lcn;
import 'package:rxdart/rxdart.dart';

class NewTripPage extends StatefulWidget {
  static const String id = 'trip';
  final TripDetails tripDetails;

  NewTripPage({required this.tripDetails});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  late GoogleMapController rideMapController;
  final Completer<GoogleMapController> _completer = Completer();
  lcn.Location location = lcn.Location();
  double lat = 0;
  double lng = 0;
  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polylines = Set<Polyline>();
  double mapPaddingBottom = 0;
  late Position myPosition;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
    BackgroundLocation.startLocationService();
  }

// Stateful Data
  BehaviorSubject<double> radius = BehaviorSubject();
  late Stream<dynamic> query;

  // Subscription
  StreamSubscription? subscription;

  var geoLocator = Geolocator();
  Geoflutterfire geo = Geoflutterfire();
  var locationOptions =
      const LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  late BitmapDescriptor movingMarkerIcon;

  void createMarker() {
    ImageConfiguration imageConfiguration =
        createLocalImageConfiguration(context, size: const Size(2, 2));
    BitmapDescriptor.fromAssetImage(imageConfiguration,
            (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png')
        .then((icon) {
      movingMarkerIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            // padding: EdgeInsets.only(bottom: mapPaddingBottom),
            circles: _circles,
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            trafficEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) async {
              _completer.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPaddingBottom = (Platform.isIOS) ? 255 : 260;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.tripDetails.pickup;
              var destinationLatLng = widget.tripDetails.destination!;
              print("Pickup:${pickupLatLng} destination${destinationLatLng}");
              await getDirection(pickupLatLng!, destinationLatLng);
              getLocationUpdates(destinationLatLng,widget.tripDetails.rideId);
            },
          ),
        ],
      ),
    );
  }

  void getLocationUpdates(destinationLatLng,id) {
    LatLng oldPosition = LatLng(0, 0);
    ridePositionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions)
            .listen((Position position) {
      myPosition = position;
      currentPosition = position;
      print("Currentposition->${position.latitude}||${position.longitude}");
      updateToDb(position,destinationLatLng,id);
      LatLng pos = LatLng(position.latitude, position.longitude);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, position.latitude, pos.longitude);


      Marker movingMarker = Marker(
          markerId: const MarkerId("moving"),
          position: pos,
          rotation: rotation,
          icon: movingMarkerIcon,
          infoWindow: const InfoWindow(title: "Current Location"));

      setState(() {
        CameraPosition cp = CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });
      oldPosition = pos;
    });
  }

  Future<void> updateToDb(pos,destinationLatLng,id) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.reference().child("cargos/$id/from_lat_lng");

    print(pos.latitude.toString());
    print(lat);
    print(pos.longitude.toString());
    print(lng);
    if (pos.latitude.toString() != lat.toString() &&
        pos.longitude.toString() != lng.toString()) {
      Map position = {"latitude": pos.latitude, 'longitude': pos.longitude};
      ref.set(position);
      print("AddedToDB");
      LatLng polyPosition = LatLng(pos.latitude, pos.longitude);
      // updatePolyLines(polyPosition, destinationLatLng);
    }
    setState(() {
      lat = pos.latitude;
      lng = pos.longitude;
    });
  }

  void acceptTrip() {
    String? rideId = widget.tripDetails.rideId;
    print("RideId,$rideId");
    setState(() {
      rideRef =
          FirebaseDatabase.instance.reference().child("cargos/$rideId");
    });
    rideRef.child('status').set('ongoing');
  }

  Future<void> updatePolyLines(LatLng pickupLatLng, LatLng destinationLatLng) async {
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, destinationLatLng);
    print("This details,$thisDetails");
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
    polylinePoints.decodePolyline(thisDetails!.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      for (var point in results) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyid'),
        color: const Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
          LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.latitude),
          northeast:
          LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));

  //   Marker pickupMarker = Marker(
  //     markerId: const MarkerId('pickup'),
  //     position: pickupLatLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //   );
  //
  //   Marker destinationMarker = Marker(
  //     markerId: const MarkerId('drop'),
  //     position: destinationLatLng,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //   );
  //   setState(() {
  //     _markers.add(pickupMarker);
  //     _markers.add(destinationMarker);
  //   });
  //   print("Markers,$_markers");
  //
  //   Circle pickupCircle = Circle(
  //       circleId: const CircleId('pickup'),
  //       strokeColor: BrandColors.colorGreen,
  //       strokeWidth: 3,
  //       radius: 12,
  //       center: pickupLatLng,
  //       fillColor: BrandColors.colorGreen);
  //
  //   Circle destinationCircle = Circle(
  //       circleId: const CircleId('destination'),
  //       strokeColor: BrandColors.colorAccentPurple,
  //       strokeWidth: 3,
  //       radius: 12,
  //       center: destinationLatLng,
  //       fillColor: BrandColors.colorAccentPurple);
  //
  //   setState(() {
  //     _circles.add(pickupCircle);
  //     _circles.add(destinationCircle);
  //   });
  // }
}

  Future<void> getDirection(
      LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            const ProgressDialog(status: 'Please wait...'),
        barrierDismissible: false);
    var thisDetails = await HelperMethods.getDirectionsDetails(
        pickupLatLng, destinationLatLng);
    print("This details,$thisDetails");
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails!.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      for (var point in results) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyid'),
        color: const Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.latitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 10));

    Marker pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('drop'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });
    print("Markers,$_markers");

    Circle pickupCircle = Circle(
        circleId: const CircleId('pickup'),
        strokeColor: BrandColors.colorGreen,
        strokeWidth: 3,
        radius: 12,
        center: pickupLatLng,
        fillColor: BrandColors.colorGreen);

    Circle destinationCircle = Circle(
        circleId: const CircleId('destination'),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: destinationLatLng,
        fillColor: BrandColors.colorAccentPurple);

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }
}
