import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cargo_driver/datamodels/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


User currentUser = FirebaseAuth.instance.currentUser!;

const CameraPosition googlePlex = CameraPosition(target: LatLng(12.295810,76.639381),zoom: 16);

String mapKey = 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs';



StreamSubscription<Position>? homePositionStream;


StreamSubscription<Position>? ridePositionStream;

late WebSocketChannel channel;

final assetsAudioPlayer = AssetsAudioPlayer();
late Position currentPosition;

DatabaseReference rideRef = FirebaseDatabase.instance.reference().child("rideRequest");

Driver currentDriverInfo = Driver("XYZ","xyz", "xyz", 'xyz', 'xyz', 'xyz', 'xyz');

bool isAvailable = false;