import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/screens/mainpage.dart';
import 'package:cargo_driver/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class VehicleInfoPage extends StatelessWidget {


  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }



  static const String id = "vehicleinfo";

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();


  void updateProfile(context){
    String id = currentUser.uid;
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');
    Map map = {
      'car_color':carColorController.text,
      'car_model':carModelController.text,
      'vehicle_number':vehicleNumberController.text
    };
    ref.set(map);
    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }



  VehicleInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20,),
              Image.asset('images/logo.png',height: 110,width: 110,),
              Padding(
                padding:  const EdgeInsets.fromLTRB(30,20,30,30),
                child: Column(
                  children: <Widget> [
                    const Text("Enter Vehicles Details",style: TextStyle(fontFamily: 'Brand-Bold',fontSize: 22),),
                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 10,),
                     TextField(
                       controller: carColorController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Car Color',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 10,),
                     TextField(
                       controller: vehicleNumberController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Vehicle Number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 40.0,),
                    TaxiOutlineButton(
                        title:'PROCEED',
                        onPressed: (){
                          if(carModelController.text.length<3){
                            showSnackBar("Please provide the valid car model");
                            return;
                          }
                          if(carColorController.text.length<3){
                            showSnackBar("Please provide the valid car color");
                            return;
                          }
                          if(vehicleNumberController.text.length<3){
                            showSnackBar("Please provide the valid Vehicle number");
                            return;
                          }
                          updateProfile(context);

                        },
                        color: BrandColors.colorGreen),


                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
