import 'package:flutter/material.dart';
import 'package:online_contacts/constants/splashScreen.dart';
import 'package:online_contacts/pageAuth/controlAuth.dart';
import 'package:provider/provider.dart';

void main() => runApp(MonApp());

class MonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Utilisateur>.value(
      value: StreamProviderAuth().utilisateur,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
