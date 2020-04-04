import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:online_contacts/pageAuth/controlAuth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), () => Navigator.push(context, MaterialPageRoute(
      builder: (context) => Passerelle()
    )));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 180.0),
          Image.asset('assets/logo.png', height: 100.0, width: 100.0,),
          SizedBox(height: 20.0),
          SpinKitChasingDots(
            color: Colors.amber,
            size: 50.0,
          )
        ],
      ),
    );
  }
}
