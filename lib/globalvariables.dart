import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


User currentUser = FirebaseAuth.instance.currentUser!;

const CameraPosition googlePlex = CameraPosition(target: LatLng(12.295810,76.639381),zoom: 14.4746);

String mapKey = 'AIzaSyDesMubxml8BIY1XrmziNdS6y6cNGoFBTs';



StreamSubscription<Position> homePositionStream = Geolocator.getPositionStream() as StreamSubscription<Position>;

final assetsAudioPlayer = AssetsAudioPlayer();