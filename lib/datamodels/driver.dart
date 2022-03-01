import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class Driver{
  late String fullName;
  late String email;
  late String phone;
  late String id;
  late String carModel;
  late String carColor;
  late String vehicleNumber;

  Driver(this.fullName, this.email, this.phone, this.id, this.carModel,
      this.carColor, this.vehicleNumber);

  Driver.fromSnapShot(DataSnapshot snapshot){
    final myData = json.decode(json.encode(snapshot.value));
    print("myData,$myData");
    id = snapshot.key!;
    fullName = myData['fullname'];
    email = myData['email'];
    phone = myData['phone'];
    carModel = myData['vehicle_details']['car_model'];
    carColor = myData['vehicle_details']['car_color'];
    vehicleNumber = myData['vehicle_details']['vehicle_number'];

  }


}