import 'package:cargo_driver/globalvariables.dart';
import 'package:cargo_driver/screens/vehicleinfo.dart';
import 'package:cargo_driver/widgets/ProgressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../brand_colors.dart';
import 'loginpage.dart';
import 'mainpage.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content:Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async{
    showDialog(context: context,
        builder: (BuildContext context)=> const ProgressDialog(status: 'Registering You..'));
    final User? user = (await _auth.createUserWithEmailAndPassword(
        email:emailController.text,
        password:passwordController.text
    ).catchError((ex){
      Navigator.pop(context);
      showSnackBar(ex.message.toString());
    })).user;
    Navigator.pop(context);

    if (user!=null){
      DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      Map userMap = {
        'fullname':fullNameController.text,
        'email':emailController.text,
        'phone':phoneController.text,
        'role':'DRIVER'
      };
      newUserRef.set(userMap);
      currentUser = user;
      Navigator.pushNamed(context, VehicleInfoPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children:  <Widget>[

                const SizedBox(height: 40,),
                const Text('Sign Up as a Driver',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25,fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children:  <Widget> [
                      // Full Name
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      // Phone Number
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10,),
                      //password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 40,),
                      RaisedButton(
                        onPressed: () async{

                          // check for internet connectivity
                          var connectivityRes = await Connectivity().checkConnectivity();
                          if(connectivityRes!=ConnectivityResult.mobile && connectivityRes !=ConnectivityResult.wifi){
                            showSnackBar('No Internet Connection');
                            return;
                          }

                          //name validation
                          if(fullNameController.text.isEmpty){
                            showSnackBar("Name is Required");
                            return;
                          }
                          // email validation
                          if (!emailController.text.contains('@')){
                            showSnackBar("Enter Proper Email");
                            return;
                          }
                          // phone number validation
                          if (phoneController.text.length<10 ||phoneController.text.length>10 ){
                            showSnackBar("Check your Phone number");
                            return;
                          }

                          // password validation
                          if(passwordController.text.length<6){
                            showSnackBar('Password Should be minimum 6 characters long!');
                            return;
                          }

                          registerUser();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: BrandColors.colorOrange,
                        textColor: Colors.white,
                        child: const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold'),
                            ),
                          ),
                        ),

                      ),
                      const SizedBox(height: 40,),
                    ],
                  ),
                ),
                FlatButton(onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
                  child:const Text('Already have a Driver account? Login'),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
