import 'package:cargo_driver/datamodels/tripdetails.dart';
import 'package:flutter/material.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;
  NewTripPage({required this.tripDetails});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Trip"),
      ),
    );
  }
}
