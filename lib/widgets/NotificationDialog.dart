import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/datamodels/tripdetails.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/helpers/helpermethods.dart';
import 'package:cargo_driver/screens/newtrippage.dart';
import 'package:cargo_driver/widgets/BrandDivider.dart';
import 'package:cargo_driver/widgets/ProgressDialog.dart';
import 'package:cargo_driver/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialog extends StatelessWidget {

  final TripDetails tripDetails;
  NotificationDialog({required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 30.0,
            ),
            Image.asset(
              'images/taxi.png',
              width: 100,
            ),
            const SizedBox(
              height: 16.0,
            ),
            const Text(
              "NEW TRIP REQUEST",
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children:<Widget> [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/pickicon.png',height: 16,width: 16,),
                      const SizedBox(width: 18,),
                      Expanded(child: Container(child: Text(tripDetails.pickupAddress!,style:TextStyle(fontSize: 18),)))
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset("images/desticon.png",height: 16,width: 16,),
                      const SizedBox(width: 18,),
                      Expanded(child: Container(child: Text(tripDetails.destinationAddress!,style: TextStyle(fontSize: 18),)))
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            const BrandDivider(),
            const SizedBox(height: 8,),
            Padding(
                padding:const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                        child: TaxiOutlineButton(
                          title: 'DECLINE',
                          color: BrandColors.colorDimText,
                          onPressed: () async {
                            assetsAudioPlayer.stop();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                  ),
                  const SizedBox(width: 10.0,),
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailability(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailability(context){

    showDialog(context: context,
        builder:(BuildContext context) =>  ProgressDialog(status: "Accepting Request",),barrierDismissible: false);
    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentUser.uid}/newtrip');
    newRideRef.once().then((value){
      final dataSnapShoot = value.snapshot;
      String thisRideId = "";
      Navigator.pop(context);
      Navigator.pop(context);

      if (dataSnapShoot.value.toString().isNotEmpty){
        thisRideId = dataSnapShoot.value.toString();
      }else{
        Fluttertoast.showToast(
            msg: "This Ride has been Cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0

        );
      }
      print("received ride id$thisRideId");
      print("class ride id${tripDetails.rideId}");
      if(thisRideId==tripDetails.rideId){
        newRideRef.set('-MvMblFOZehJPnprqnif');
        HelperMethods.disableHomeTabLocationUpdates();
        Navigator.push(context,
        MaterialPageRoute(builder: (context)=> NewTripPage(tripDetails: tripDetails,)));
      }else if(thisRideId == 'cancelled'){
        Fluttertoast.showToast(
            msg: "This Ride has been Cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0

        );
      }
      else if(thisRideId == 'timeout'){
        Fluttertoast.showToast(
            msg: "Ride has time out",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0

        );
      }else{
        Fluttertoast.showToast(
            msg: "Ride not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0

        );

      }
    });
  }
}
