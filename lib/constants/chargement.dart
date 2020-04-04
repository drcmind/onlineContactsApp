import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Chargement extends StatefulWidget {
  @override
  _ChargementState createState() => _ChargementState();
}

class _ChargementState extends State<Chargement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 200.0),
          Image.asset('assets/logo.png', height: 100.0, width: 100.0),
          SizedBox(height: 10.0),
          SpinKitChasingDots(
            color: Colors.amber,
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
