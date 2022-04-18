import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cargo_driver/datamodels/tripdetails.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/widgets/NotificationDialog.dart';
import 'package:cargo_driver/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {

  late FirebaseMessaging messaging;
  String rideId = "";


  Future<String> getToken(context) async {
    messaging = FirebaseMessaging.instance;
    String token;

    messaging.getToken().then((value) {
      token = value.toString();
      print("Token $token");
      DatabaseReference ref = FirebaseDatabase.instance.reference().child(
          'drivers/${currentUser.uid}/token');
      ref.set(token);
      messaging.subscribeToTopic('allDrivers');
      messaging.subscribeToTopic('allUsers');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print("Message Received");
      rideId = message.data['ride_id'];
      print("Rideid,$rideId");
      fetchRideInfo(rideId,context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("message_data,${message.data}");
      rideId = message.data['ride_id'];
      fetchRideInfo(rideId,context);
    });

    return '0';
  }
  void fetchRideInfo(String rideId,context){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder:(BuildContext context) => const ProgressDialog(status: "Loading.."));
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    rideRef.once().then((value){
      final dataSnapshot = value.snapshot;
      Navigator.pop(context);

      assetsAudioPlayer.open(Audio('sounds/alert.mp3'),);
      assetsAudioPlayer.play();
      final myData = json.decode(json.encode(dataSnapshot.value));
      double pickupLat = double.parse(myData["pickup"]["latitude"].toString());
      double pickupLng = double.parse(myData["pickup"]["longitude"].toString());
      String pickupAddress = myData['pickup_address'].toString();

      double destinationLat = double.parse(myData["destination"]["latitude"].toString());
      double destinationLng = double.parse(myData["destination"]["longitude"].toString());

      String destinationAddress = myData['destination_address'].toString();

      String paymentMethod = myData['payment_method'];

      TripDetails tripDetails = TripDetails();
      tripDetails.rideId = rideId;
      tripDetails.pickupAddress = pickupAddress;
      tripDetails.destinationAddress = destinationAddress;
      tripDetails.pickup = LatLng(pickupLat,pickupLng);
      tripDetails.destination = LatLng(destinationLat, destinationLng);
      tripDetails.paymentMethod = paymentMethod;


      showDialog(context: context,
          builder: (BuildContext context)=> NotificationDialog(tripDetails: tripDetails ,),barrierDismissible: false);

    });
  }

}

