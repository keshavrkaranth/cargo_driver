import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails{
  String? destinationAddress;
  String? pickupAddress;
  LatLng? pickup;
  LatLng? destination;
  String? rideId;
  String? paymentMethod;
  String? raiderName;
  String? riderPhone;

  TripDetails({
    this.pickupAddress,
    this.pickup,
    this.rideId,
    this.destination,
    this.destinationAddress,
    this.paymentMethod,
    this.raiderName,
    this.riderPhone
});

}