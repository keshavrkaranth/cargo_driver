import 'dart:convert';
import 'dart:math';

import 'package:cargo_driver/datamodels/directiondetails.dart';
import 'package:cargo_driver/helpers/requesthelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';

import '../globalvariables.dart';

class HelperMethods {



  static Future<DirectionDetails?> getDirectionsDetails(LatLng start,LatLng end) async{
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if(response == 'failed'){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
        durationText: response['routes'][0]['legs'][0]['duration']['text'],
        durationValue: response['routes'][0]['legs'][0]['duration']['value'].toString(),
        distanceText: response['routes'][0]['legs'][0]['distance']['text'],
        distanceValue: response['routes'][0]['legs'][0]['distance']['value'].toString(),
        encodedPoints: response['routes'][0]['overview_polyline']['points'].toString()
    );
    return directionDetails;
  }

  static int estimateFares(DirectionDetails details){
    double baseFare = 3;
    double distanceFare = (int.parse(details.distanceValue)/1000)*0.3;
    double timeFare = (int.parse(details.distanceValue)/60)*0.2;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();

  }


  static double generateRandomNumber(int max){
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);
    return randInt.toDouble();
  }

  static void disableHomeTabLocationUpdates(){
    homePositionStream?.pause();
    Geofire.setLocation(currentUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void enableHomeTabLocationUpdates(){
    homePositionStream?.resume();
    Geofire.setLocation(currentUser.uid, currentPosition.latitude, currentPosition.longitude);
  }
}
